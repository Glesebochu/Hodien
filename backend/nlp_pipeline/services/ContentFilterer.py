from datetime import datetime
from .ContentHumorAnalyzer import ContentHumorAnalyzer
from ...shared_utils.models.Content import Content
import os
import csv
import re
import emoji


class ContentFilterer:
    def __init__(self):
        self.analyzer = ContentHumorAnalyzer()
        self.processed_log = []  # Each entry: {"content": content, "timestamp": datetime}
        
    def normalize(self, file):
        # Check if the file is a CSV file and return an error message if it isn't
        if not file.endswith('.csv'):
            raise ValueError("The provided file is not a CSV file.")
        

        # Create a new file called normalized_jokes.csv after checking if it exists
        output_file = os.path.join("backend", "nlp_pipeline", "data", "normalized_jokes.csv")
        if os.path.exists(output_file):
            os.remove(output_file)

        # Create a data structure to hold the normalized jokes, call it normalized
        normalized = []

        # Write the header with the following column names: id, text, emoji_presence
        header = ["id", "text", "emoji_presence"]

        # For every line in the file parameter
        with open(file, mode='r', encoding='utf-8') as infile:
            reader = csv.DictReader(infile)
            for row in reader:
                # Make everything upper case
                text = row["text"].lower()

                # Check if there are any emojis and save that value as a boolean
                emoji_presence = any(char in emoji.EMOJI_DATA for char in text)

                # Check if there are any links and remove them.
                text = re.sub(r'http\S+|www\S+|https\S+', '', text)

                # Add this to the normalized jokes data structure.
                normalized.append({"id": row["id"], "text": text, "emoji_presence": emoji_presence})

        # Save everything to a new file called normalized_jokes.csv
        with open(output_file, mode='w', encoding='utf-8', newline='') as outfile:
            writer = csv.DictWriter(outfile, fieldnames=header)
            writer.writeheader()
            writer.writerows(normalized)

    def filter_pre_nlp(self, contents: list):
        """
        Simple filtering logic before NLP: removes empty texts or invalid formats.
        """
        return [post for post in contents if isinstance(post.text, str) and post.text.strip()]

    def remove_below_threshold(self, contents: list, threshold: float):
        """
        Calls analyzer functions and removes content with low humor score.
        """
        self.analyzer.classify_content(contents)
        self.analyzer.extract_metadata(contents)

        filtered = []
        for content in contents:
            if content.humor_score >= threshold:
                filtered.append(content)
                self.processed_log.append({
                    "content": content,
                    "timestamp": datetime.now()
                })
        return filtered

    def get_processed_data(self, start_time: datetime, end_time: datetime):
        """
        Returns count of contents processed between the start and end times.
        """
        return sum(start_time <= entry["timestamp"] <= end_time for entry in self.processed_log)