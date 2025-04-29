# Import necessary libraries
import numpy as np
import pandas as pd
import transformers as ppb
import tensorflow as tf
from sklearn.model_selection import train_test_split
import re
from nltk.stem import WordNetLemmatizer
from nltk.tokenize import regexp_tokenize
import os
import nltk

class HumorTypeClassifier:
    def __init__(self, load_finetuned=False, model_path="finetuned_humor_type_model"):
        """
        Initialize the HumorTypeClassifier.
        :param load_finetuned: Whether to load a fine-tuned model.
        :param model_path: Path to the fine-tuned model.
        """
        # Download NLTK WordNet resource if not already available
        try:
            nltk.data.find('corpora/wordnet.zip')
        except LookupError:
            print("Downloading NLTK WordNet resource...")
            nltk.download('wordnet')

        # Define humor categories
        self.humor_categories = [
            "Physical/Slapstick",
            "Wordplay/Puns",
            "Situational Humor",
            "Critical Humor",
        ]

        # Initialize tokenizer and model
        self.tokenizer = ppb.AutoTokenizer.from_pretrained("microsoft/MiniLM-L12-H384-uncased")
        if load_finetuned and os.path.exists(model_path):
            print(f"Loading fine-tuned model from {model_path}")
            self.model = ppb.TFAutoModelForSequenceClassification.from_pretrained(model_path)
        else:
            self.model = ppb.TFAutoModelForSequenceClassification.from_pretrained(
                "microsoft/MiniLM-L12-H384-uncased", num_labels=len(self.humor_categories)
            )

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
        tokenized = self.tokenizer(
            text, padding=True, truncation=True, max_length=64, return_tensors="tf"
        )
        return tokenized

    def process(self, data):
        cleaned = self.clean(data)
        return self.tokenize(cleaned)

    def predict(self, text):
        """
        Predict the humor category of a given text.
        :param text: Input text (string or list of strings).
        :return: Predicted category and confidence scores.
        """
        if isinstance(text, str):
            text = [text]

        tokenized_text = self.tokenize(text)
        predictions = self.model.predict(x=tokenized_text.input_ids)
        scores = tf.nn.softmax(predictions[0], axis=1).numpy()
        predicted_labels = [self.humor_categories[np.argmax(score)] for score in scores]
        return predicted_labels, scores

    def train(self, data_path, model_save_path="finetuned_humor_type_model"):
        """
        Train the HumorTypeClassifier on labeled data.
        :param data_path: Path to the training data CSV file.
        :param model_save_path: Path to save the fine-tuned model.
        """
        # Load data
        data = pd.read_csv(data_path)

        # Ensure the data has the required columns
        if "text" not in data.columns or "humorous" not in data.columns:
            raise KeyError("Expected columns 'text' and 'humorous' not found in the data file")

        # Map humorous to indices
        data["humorous_idx"] = data["humorous"].apply(lambda x: self.humor_categories.index(x))

        # Split data into training and validation sets
        train_texts, val_texts, train_humorous, val_humorous = train_test_split(
            data["text"], data["humorous_idx"], test_size=0.2, random_state=42
        )

        # Process data
        train_batch = self.process(train_texts.tolist())
        val_batch = self.process(val_texts.tolist())

        # Compile model
        optimizer = tf.keras.optimizers.Adam(learning_rate=2e-5, epsilon=1e-8)
        loss = tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True)
        metrics = [tf.keras.metrics.SparseCategoricalAccuracy("accuracy")]
        self.model.compile(optimizer=optimizer, loss=loss, metrics=metrics)

        # Train model
        self.model.fit(
            x=train_batch.input_ids,
            y=np.array(train_humorous),
            validation_data=(val_batch.input_ids, np.array(val_humorous)),
            epochs=3,
            batch_size=8
        )

        # Save the fine-tuned model
        self.model.save_pretrained(model_save_path)
        print(f"Model saved to {model_save_path}")

    def predict_score_bulk(self, input_csv_path, output_csv_path="classified_jokes.csv"):
        """
        Predict humor categories and scores for a bulk of text data from a CSV file.
        :param input_csv_path: Path to the input CSV file containing text data.
        :param output_csv_path: Path to save the output CSV file with predictions and scores.
        """
        # Read the input CSV file
        input_data = pd.read_csv(input_csv_path)

        # Ensure the input CSV has a 'text' column
        if "text" not in input_data.columns:
            raise KeyError("Expected column 'text' not found in the input CSV file")

        # Create a copy of the input data to preserve all existing columns
        scored_data = input_data.copy()

        # Add new columns for predictions and humor scores
        scored_data["humor_type"] = None
        scored_data["humor_type_score"] = None

        # Process each row in the input file
        for idx, text in enumerate(input_data["text"]):
            # Call the predict() function
            predicted_label, humor_type_score = self.predict([text])

            # Add the humor_type (prediction) and humor_type_score to the corresponding columns
            scored_data.at[idx, "humor_type"] = predicted_label[0]
            scored_data.at[idx, "humor_type_score"] = humor_type_score[0][np.argmax(humor_type_score[0])]

        # Save the updated data to a CSV file
        scored_data.to_csv(output_csv_path, index=False)
        print(f"Scored data saved to {output_csv_path}")