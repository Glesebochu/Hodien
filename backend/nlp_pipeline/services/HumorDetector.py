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
    def __init__(self):
        # Download NLTK WordNet resource if not already available
        try:
            nltk.data.find('corpora/wordnet.zip')
        except LookupError:
            print("Downloading NLTK WordNet resource...")
            nltk.download('wordnet')

        # Initialize tokenizer and model
        self.tokenizer = ppb.AutoTokenizer.from_pretrained("bert-base-uncased")
        self.model = ppb.TFBertForSequenceClassification.from_pretrained("bert-base-uncased")

    def lemmatize(self, s):
        wordnet_lemmatizer = WordNetLemmatizer()
        return " ".join([wordnet_lemmatizer.lemmatize(w, 'v') for w in s.split(" ")])

    def lower(self, s):
        return s.lower()

    def clean(self, data):
        cleaned_data = []
        for item in data:
            item = self.lemmatize(item)
            item = self.lower(item)
            item = re.sub(r'\d+', '', item)  # remove numbers
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

    def classify_content(self, content):
        tokenized_content = self.tokenize(content)
        prediction = self.model.predict(x=tokenized_content.input_ids)
        return np.argmax(prediction[0], axis=1)

    @staticmethod
    def train_classifier():
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

        # Initialize classifier
        classifier = HumorDetector()

        # Process training and testing data
        train_batch = classifier.process(train_x)
        test_batch = classifier.process(test_x)

        # Set up TensorFlow model for fine-tuning BERT
        learning_rate = 2e-5
        epochs = 10
        optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate, epsilon=1e-8)
        loss = tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True)
        metric1 = tf.keras.metrics.SparseCategoricalAccuracy('accuracy')
        metric2 = tf.keras.metrics.Precision(name="precision")
        metric3 = tf.keras.metrics.Recall(name="recall")
        classifier.model.compile(optimizer=optimizer, loss=loss, metrics=[metric1])

        # Train the model
        history = classifier.model.fit(x=train_batch.input_ids, y=np.array(train_y), epochs=epochs)

        # Evaluate the model
        classifier.model.evaluate(x=test_batch.input_ids, y=np.array(test_y))

        # Generate predictions
        y_pred = classifier.model.predict(x=test_batch.input_ids)
        y_pred_bool = np.argmax(y_pred[0], axis=1)

        # Print classification report
        print(classification_report(test_y, y_pred_bool))

        # Test the model with a sample input
        result = classifier.classify_content("When my son told me to stop impersonating a flamingo, I had to put my foot down.")
        print(result)

        # Save predictions to a CSV file
        submission = pd.DataFrame({"Prediction": y_pred_bool})
        submission.to_csv("predictions.csv", index=True, index_label="Id")