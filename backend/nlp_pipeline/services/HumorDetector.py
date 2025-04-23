# Import necessary libraries
import numpy as np  # linear algebra
import pandas as pd  # data processing, CSV file I/O (e.g. pd.read_csv)
import transformers as ppb  # BERT Model
import tensorflow as tf
from sklearn.neural_network import MLPClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import cross_val_score
import re
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import regexp_tokenize
import os
from sklearn.metrics import classification_report, confusion_matrix, ConfusionMatrixDisplay
import nltk  # Add this import for downloading NLTK resources
from nltk.corpus import stopwords  # Import stopwords
import matplotlib.pyplot as plt
import yaml  # For configuration file parsing
from tensorflow.keras.backend import clear_session
import logging  # For logging

os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ["OMP_NUM_THREADS"] = "4"
os.environ["TF_NUM_INTRAOP_THREADS"] = "4"
os.environ["TF_NUM_INTEROP_THREADS"] = "2"

# Enable GPU usage if available
if tf.config.list_physical_devices('GPU'):
    print("\nGPU is available. Using GPU for training.\n")
else:
    print("\nGPU is not available. Using CPU for training.\n")

# Configure logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")
logger = logging.getLogger(__name__)

class HumorDetector:
    def __init__(self, config_path="config.yaml", load_finetuned=False):
        """
        Initialize the HumorDetector class.

        Args:
            config_path (str): Path to the YAML configuration file.
            load_finetuned (bool): Whether to load a fine-tuned model from the specified path.
        """
        # Load configuration from YAML file
        with open(config_path, "r") as file:
            self.config = yaml.safe_load(file)

        self.model_path = self.config.get("model_path", "finetuned_minilm")
        self.batch_size = self.config.get("batch_size", 32)

        # Download NLTK WordNet resource if not already available
        try:
            nltk.data.find('corpora/wordnet.zip')
        except LookupError:
            print("Downloading NLTK WordNet resource...")
            nltk.download('wordnet')
        try:
            nltk.data.find('corpora/stopwords.zip')
        except LookupError:
            print("Downloading NLTK Stopwords resource...")
            nltk.download('stopwords')

        # Use MiniLM for faster training
        self.tokenizer = ppb.AutoTokenizer.from_pretrained("microsoft/MiniLM-L12-H384-uncased")
        if load_finetuned and os.path.exists(self.model_path):
            print(f"Loading fine-tuned model from {self.model_path}")
            self.model = ppb.TFAutoModelForSequenceClassification.from_pretrained(self.model_path)
        else:
            self.model = ppb.TFAutoModelForSequenceClassification.from_pretrained("microsoft/MiniLM-L12-H384-uncased")

    def lemmatize(self, s):
        """
        Lemmatize a given string.

        Args:
            s (str): Input string to lemmatize.

        Returns:
            str: Lemmatized string.
        """
        wordnet_lemmatizer = WordNetLemmatizer()
        return " ".join([
            wordnet_lemmatizer.lemmatize(w, pos) 
            for w in s.split(" ") 
            for pos in ['v', 'n', 'a']  # Lemmatize as verb, noun, and adjective
        ])

    def lower(self, s):
        """
        Convert a string to lowercase.

        Args:
            s (str): Input string.

        Returns:
            str: Lowercased string.
        """
        return s.lower()

    def clean(self, data):
        """
        Clean a list of text data by removing stopwords, punctuation, URLs, and numbers.

        Args:
            data (list): List of strings to clean.

        Returns:
            list: List of cleaned strings.
        """
        stop_words = set(stopwords.words('english'))
        cleaned_data = []
        for item in data:
            item = self.lemmatize(item)
            item = self.lower(item)
            item = re.sub(r'https?://\S+|www\.\S+', '', item)  # Remove URLs
            item = re.sub(r'[^\w\s]', '', item)  # Remove punctuation and special characters
            item = re.sub(r'\d+', '', item)  # Remove numbers
            item = " ".join([word for word in item.split() if word not in stop_words])  # Remove stopwords
            cleaned_data.append(item)
        return cleaned_data

    def tokenize(self, text):
        """
        Tokenize text using the BERT tokenizer.

        Args:
            text (list or str): Input text or list of texts.

        Returns:
            dict: Tokenized text as tensors.
        """
        # Reduce max_length for faster processing
        tokenized = self.tokenizer(
            text, padding=True, truncation=True, max_length=64, return_tensors="tf"
        )
        return tokenized

    def process(self, data):
        """
        Clean and tokenize input data.

        Args:
            data (list): List of strings to process.

        Returns:
            dict: Tokenized tensors.
        """
        cleaned = self.clean(data)
        return self.tokenize(cleaned)

    def predict(self, content):
        """
        Predict humor labels and scores for input text.

        Args:
            content (str or list): Input text or list of texts.

        Returns:
            tuple: Predicted labels and humor scores.
        """
        # Handle single input explicitly
        if isinstance(content, str):
            content = [content]  # Convert single string to a list
        tokenized_content = self.tokenize(content)
        prediction = self.model.predict(x=tokenized_content.input_ids)
        humor_score = tf.nn.softmax(prediction[0], axis=1).numpy()
        predicted_label = np.argmax(humor_score, axis=1)
        return predicted_label, humor_score

    def validate_csv(self, csv_path, required_columns):
        """
        Validate the CSV file format and ensure required columns are present.

        Args:
            csv_path (str): Path to the CSV file.
            required_columns (list): List of required column names.

        Returns:
            pd.DataFrame: Loaded and validated DataFrame.
        """
        try:
            data = pd.read_csv(csv_path)
        except Exception as e:
            raise ValueError(f"Error reading CSV file at {csv_path}: {e}")

        missing_columns = [col for col in required_columns if col not in data.columns]
        if missing_columns:
            raise KeyError(f"Missing required columns in {csv_path}: {missing_columns}")

        return data

    def predict_score_bulk(self, input_csv_path, output_csv_path="scored_jokes.csv", batch_size=32, text_column="text"):
        """
        Predict humor scores for a bulk of text data from a CSV file.

        Args:
            input_csv_path (str): Path to the input CSV file.
            output_csv_path (str): Path to save the output CSV file with predictions.
            batch_size (int): Batch size for processing.
            text_column (str): Name of the column containing text data.

        Returns:
            None
        """
        # Validate the input CSV file
        input_data = self.validate_csv(input_csv_path, required_columns=[text_column])

        # Create a copy of the input data to preserve all existing columns
        scored_data = input_data.copy()

        # Add new columns for predictions and humor scores
        scored_data["humorous"] = None
        scored_data["humor_score"] = None

        # Process texts in batches
        texts = input_data[text_column].fillna("").tolist()  # Handle missing text values
        for start_idx in range(0, len(texts), batch_size):
            batch_texts = texts[start_idx:start_idx + batch_size]
            predicted_labels, humor_scores = self.predict(batch_texts)

            # Update the scored_data DataFrame
            for idx, (label, score) in enumerate(zip(predicted_labels, humor_scores)):
                scored_data.at[start_idx + idx, "humorous"] = label
                scored_data.at[start_idx + idx, "humor_score"] = score[label]

        # Save the updated data to a CSV file
        scored_data.to_csv(output_csv_path, index=False)
        print(f"Scored data saved to {output_csv_path}")

    @staticmethod
    def create_tf_dataset(features, labels=None, batch_size=32):
        """
        Create a tf.data.Dataset for efficient data loading and batching.

        Args:
            features (np.array): Input features.
            labels (np.array, optional): Input labels. Defaults to None.
            batch_size (int): Batch size for batching.

        Returns:
            tf.data.Dataset: TensorFlow dataset object.
        """
        dataset = tf.data.Dataset.from_tensor_slices((features, labels)) if labels is not None else tf.data.Dataset.from_tensor_slices(features)
        dataset = dataset.batch(batch_size).prefetch(tf.data.AUTOTUNE)
        return dataset

    def train(self, sample_limit=None):
        """
        Train the HumorDetector model.

        Args:
            sample_limit (int, optional): Limit the number of training samples. Defaults to None.

        Returns:
            None
        """
        # Load configuration
        config = self.config
        epochs = config.get("epochs", 3)
        text_column = config.get("text_column", "text")
        label_column = config.get("label_column", "humorous")
        batch_size = self.batch_size
        learning_rate = config.get("learning_rate", 2e-5)

        # Check for Kaggle-specific directory and log files if present
        kaggle_input_dir = "/kaggle/input"
        if os.path.exists(kaggle_input_dir):
            logger.info("Kaggle environment detected. Listing input files:")
            for dirname, _, filenames in os.walk(kaggle_input_dir):
                for filename in filenames:
                    logger.info(os.path.join(dirname, filename))

        # Load and validate training and testing data
        train_data = self.validate_csv(
            "backend/nlp_pipeline/data/train_detector.csv", required_columns=[text_column, label_column]
        )
        test_data = self.validate_csv(
            "backend/nlp_pipeline/data/test_detector.csv", required_columns=[text_column, label_column]
        )

        # Separate features and labels
        train_x = train_data[text_column].fillna("")  # Handle missing text values
        train_y = train_data[label_column]
        test_x = test_data[text_column].fillna("")  # Handle missing text values
        test_y = test_data[label_column]

        # Apply sample limit if provided
        if sample_limit:
            train_x = train_x[:sample_limit]
            train_y = train_y[:sample_limit]

        # Process training and testing data
        train_batch = self.process(train_x)
        test_batch = self.process(test_x)

        # Convert to tf.data.Dataset for efficient batching
        train_dataset = self.create_tf_dataset(train_batch.input_ids, np.array(train_y), batch_size=batch_size)
        test_dataset = self.create_tf_dataset(test_batch.input_ids, np.array(test_y), batch_size=batch_size)

        # Set up TensorFlow model for fine-tuning BERT
        optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate, epsilon=1e-8)
        loss = tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True)
        metric1 = tf.keras.metrics.SparseCategoricalAccuracy('accuracy')
        metric2 = tf.keras.metrics.Precision(name="precision")
        metric3 = tf.keras.metrics.Recall(name="recall")
        self.model.compile(optimizer=optimizer, loss=loss, metrics=[metric1, metric2, metric3])

        # Add early stopping and learning rate scheduling
        early_stopping = tf.keras.callbacks.EarlyStopping(
            monitor='val_loss', patience=2, restore_best_weights=True
        )
        lr_scheduler = tf.keras.callbacks.LearningRateScheduler(
            lambda epoch: learning_rate * (0.1 ** (epoch // 2))
        )

        # Train the model
        logger.info("Starting model training...")
        history = self.model.fit(
            train_dataset,
            epochs=epochs,
            validation_data=test_dataset,
            callbacks=[early_stopping, lr_scheduler]
        )
        logger.info("Model training completed.")

        # Save the fine-tuned model
        self.model.save_pretrained(self.model_path)
        logger.info(f"Fine-tuned model saved to {self.model_path}.")

        # Evaluate the model
        evaluation_results = self.model.evaluate(test_dataset)
        logger.info(f"Evaluation results: {evaluation_results}")

        # Perform memory cleanup
        clear_session()
        logger.info("Memory cleared after training.")

        # Generate predictions
        y_pred = self.model.predict(x=test_batch.input_ids)
        y_pred_bool = np.argmax(y_pred[0], axis=1)

        # Save classification report to a file
        report = classification_report(test_y, y_pred_bool, output_dict=True)
        with open("classification_report.json", "w") as f:
            import json
            json.dump(report, f, indent=4)
        logger.info("Classification report saved to classification_report.json.")

        # Visualize confusion matrix
        cm = confusion_matrix(test_y, y_pred_bool)
        disp = ConfusionMatrixDisplay(confusion_matrix=cm, display_labels=["Not Humorous", "Humorous"])
        disp.plot(cmap=plt.cm.Blues)
        plt.title("Confusion Matrix")
        plt.savefig("confusion_matrix.png")
        plt.show()
        logger.info("Confusion matrix saved to confusion_matrix.png.")

        # Perform hyperparameter tuning using Hugging Face's hyperparameter_search
        def model_init():
            return ppb.TFDistilBertForSequenceClassification.from_pretrained("distilbert-base-uncased")

        from transformers import Trainer, TrainingArguments
        training_args = TrainingArguments(
            output_dir="./results",
            evaluation_strategy="epoch",
            save_strategy="epoch",
            learning_rate=2e-5,
            per_device_train_batch_size=8,
            num_train_epochs=epochs,
            weight_decay=0.01,
            logging_dir="./logs",
        )
        trainer = Trainer(
            model_init=model_init,
            args=training_args,
            train_dataset=train_batch,
            eval_dataset=test_batch,
        )
        best_run = trainer.hyperparameter_search(
            direction="maximize",
            n_trials=10,
            hp_space=lambda _: {
                "learning_rate": [1e-5, 2e-5, 3e-5],
                "num_train_epochs": [2, 3, 4],
                "per_device_train_batch_size": [8, 16],
            },
        )
        logger.info(f"Best hyperparameters found: {best_run.hyperparameters}")

        # Save predictions and probabilities to a CSV file
        humor_scores = np.max(tf.nn.softmax(y_pred[0], axis=1).numpy(), axis=1)  # Calculate humor scores (probabilities)
        submission = pd.DataFrame({
            "Prediction": y_pred_bool,
            "HumorScore": humor_scores
        })
        submission.to_csv("predictions.csv", index=True, index_label="Id")
        logger.info("Predictions saved to predictions.csv.")
        
    def predict_score_bulk(self, input_csv_path, output_csv_path="scored_jokes.csv", batch_size=32):
        # Read the input CSV file
        input_data = pd.read_csv(input_csv_path)

        # Ensure the input CSV has a 'text' column
        if "text" not in input_data.columns:
            raise KeyError("Expected column 'text' not found in the input CSV file")

        # Create a copy of the input data to preserve all existing columns
        scored_data = input_data.copy()

        # Add new columns for predictions and humor scores
        scored_data["humorous"] = None
        scored_data["humor_score"] = None

        # Process texts in batches
        texts = input_data["text"].tolist()
        for start_idx in range(0, len(texts), batch_size):
            batch_texts = texts[start_idx:start_idx + batch_size]
            predicted_labels, humor_scores = self.predict(batch_texts)

            # Update the scored_data DataFrame
            for idx, (label, score) in enumerate(zip(predicted_labels, humor_scores)):
                scored_data.at[start_idx + idx, "humorous"] = label
                scored_data.at[start_idx + idx, "humor_score"] = score[label]

        # Save the updated data to a CSV file
        scored_data.to_csv(output_csv_path, index=False)
        print(f"Scored data saved to {output_csv_path}")
