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
from sklearn.metrics import classification_report
import nltk  # Add this import for downloading NLTK resources
from nltk.corpus import stopwords  # Import stopwords

os.environ["TF_ENABLE_ONEDNN_OPTS"] = "0"
os.environ["OMP_NUM_THREADS"] = "4"
os.environ["TF_NUM_INTRAOP_THREADS"] = "4"
os.environ["TF_NUM_INTEROP_THREADS"] = "2"

# Enable GPU usage if available
if tf.config.list_physical_devices('GPU'):
    print("\nGPU is available. Using GPU for training.\n")
else:
    print("\nGPU is not available. Using CPU for training.\n")

class HumorDetector:
    def __init__(self, load_finetuned=False, model_path="finetuned_distilbert"):
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

        # Use a smaller, faster model
        self.tokenizer = ppb.AutoTokenizer.from_pretrained("distilbert-base-uncased")
        if load_finetuned and os.path.exists(model_path):
            print(f"Loading fine-tuned model from {model_path}")
            self.model = ppb.TFDistilBertForSequenceClassification.from_pretrained(model_path)
        else:
            self.model = ppb.TFDistilBertForSequenceClassification.from_pretrained("distilbert-base-uncased")

    def lemmatize(self, s):
        wordnet_lemmatizer = WordNetLemmatizer()
        return " ".join([
            wordnet_lemmatizer.lemmatize(w, pos) 
            for w in s.split(" ") 
            for pos in ['v', 'n', 'a']  # Lemmatize as verb, noun, and adjective
        ])

    def lower(self, s):
        return s.lower()

    def clean(self, data):
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
        # Reduce max_length for faster processing
        tokenized = self.tokenizer(
            text, padding=True, truncation=True, max_length=64, return_tensors="tf"
        )
        return tokenized

    def process(self, data):
        cleaned = self.clean(data)
        return self.tokenize(cleaned)

    def predict(self, content):
        # Handle single input explicitly
        if isinstance(content, str):
            content = [content]  # Convert single string to a list
        tokenized_content = self.tokenize(content)
        prediction = self.model.predict(x=tokenized_content.input_ids)
        humor_score = tf.nn.softmax(prediction[0], axis=1).numpy()
        predicted_label = np.argmax(humor_score, axis=1)
        return predicted_label, humor_score

    @staticmethod
    def train(sample_limit=None, epochs=3):
        # List all files under the input directory (for Kaggle environments)
        for dirname, _, filenames in os.walk('/kaggle/input'):
            for filename in filenames:
                print(os.path.join(dirname, filename))

        # Load training and testing data from CSV files
        train_data = pd.read_csv("backend/nlp_pipeline/data/train_detector.csv", delimiter=',', quotechar='"', on_bad_lines='skip')
        test_data = pd.read_csv("backend/nlp_pipeline/data/test_detector.csv", delimiter=',', quotechar='"', on_bad_lines='skip')

        # Debug: Print column names to verify structure
        print("Train Data Columns:", train_data.columns)
        print("Test Data Columns:", test_data.columns)

        # Ensure correct column names
        if "text" not in train_data.columns or "humorous" not in train_data.columns:
            raise KeyError("Expected columns 'text' and 'humorous' not found in train_detector.csv")
        if "text" not in test_data.columns or "humorous" not in test_data.columns:
            raise KeyError("Expected columns 'text' and 'humorous' not found in test_detector.csv")

        # Separate features and labels
        train_x = train_data["text"]
        train_y = train_data["humorous"]
        test_x = test_data["text"]
        test_y = test_data["humorous"]
        
        # Apply sample limit if provided
        if sample_limit:
            train_x = train_x[:sample_limit]
            train_y = train_y[:sample_limit]

        # Initialize classifier
        classifier = HumorDetector()

        # Process training and testing data
        train_batch = classifier.process(train_x)
        test_batch = classifier.process(test_x)

        # Set up TensorFlow model for fine-tuning BERT
        learning_rate = 2e-5
        batch_size = 8  # Smaller batch size for less memory usage
        optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate, epsilon=1e-8)
        loss = tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True)
        metric1 = tf.keras.metrics.SparseCategoricalAccuracy('accuracy')
        metric2 = tf.keras.metrics.Precision(name="precision")
        metric3 = tf.keras.metrics.Recall(name="recall")
        classifier.model.compile(optimizer=optimizer, loss=loss, metrics=[metric1, metric2, metric3])

        # Add early stopping and learning rate scheduling
        early_stopping = tf.keras.callbacks.EarlyStopping(
            monitor='val_loss', patience=2, restore_best_weights=True
        )
        lr_scheduler = tf.keras.callbacks.LearningRateScheduler(
            lambda epoch: learning_rate * (0.1 ** (epoch // 2))
        )

        # Train the model with batch size
        history = classifier.model.fit(
            x=train_batch.input_ids,
            y=np.array(train_y),
            epochs=epochs,
            batch_size=batch_size,
            validation_data=(test_batch.input_ids, np.array(test_y)),
            callbacks=[early_stopping, lr_scheduler]
        )

        # Save the fine-tuned model
        classifier.model.save_pretrained("finetuned_distilbert")

        # Evaluate the model
        classifier.model.evaluate(x=test_batch.input_ids, y=np.array(test_y))

        # Generate predictions
        y_pred = classifier.model.predict(x=test_batch.input_ids)
        y_pred_bool = np.argmax(y_pred[0], axis=1)

        # Print classification report
        print(classification_report(test_y, y_pred_bool))

        # Perform cross-validation
        print("Performing cross-validation...")
        cross_val_scores = cross_val_score(
            MLPClassifier(), train_batch.input_ids.numpy(), train_y, cv=5, scoring='accuracy'
        )
        print(f"Cross-validation scores: {cross_val_scores}")
        print(f"Mean cross-validation accuracy: {np.mean(cross_val_scores)}")

        # Test the model with a sample input
        result = classifier.predict("When my son told me to stop impersonating a flamingo, I had to put my foot down.")
        print("Result: ", result)

        # Save predictions and probabilities to a CSV file
        humor_scores = np.max(tf.nn.softmax(y_pred[0], axis=1).numpy(), axis=1)  # Calculate humor scores (probabilities)
        submission = pd.DataFrame({
            "Prediction": y_pred_bool,
            "HumorScore": humor_scores
        })
        submission.to_csv("predictions.csv", index=True, index_label="Id")
        
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
