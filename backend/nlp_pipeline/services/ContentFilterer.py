from datetime import datetime
from backend.nlp_pipeline.services import ContentHumorAnalyzer


class ContentFilterer:
    def __init__(self):
        self.analyzer = ContentHumorAnalyzer()
        self.processed_log = []  # Each entry: {"content": content, "timestamp": datetime}

    def filter_pre_nlp(self, posts: list):
        """
        Simple filtering logic before NLP: removes empty texts or invalid formats.
        """
        return [post for post in posts if isinstance(post.text, str) and post.text.strip()]

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
