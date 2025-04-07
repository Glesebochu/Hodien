from collections import defaultdict
from datetime import datetime
from typing import List, Optional

from backend.shared_utils.models.Content import Content
from backend.nlp_pipeline.models.CustomError import CustomError

class MonitoringService:
    def __init__(self):
        self.error_log = []

    def calculate_humor_score_distribution(self, contents: List[Content]):
        distribution = {
            "0–2": 0,
            "2–4": 0,
            "4–6": 0,
            "6–8": 0,
            "8–10": 0
        }

        for content in contents:
            score = content.humor_score
            if score < 2:
                distribution["0–2"] += 1
            elif score < 4:
                distribution["2–4"] += 1
            elif score < 6:
                distribution["4–6"] += 1
            elif score < 8:
                distribution["6–8"] += 1
            else:
                distribution["8–10"] += 1

        return distribution

    def calculate_humor_tag_frequency(self, contents: List['Content']):
        frequency = defaultdict(int)
        for content in contents:
            humor_type = content.humor_type
            frequency[humor_type] += 1
        return dict(frequency)

    def log_error(self, error: CustomError):
        self.error_log.append({
            "message": str(error),
            "type": type(error).__name__,
            "timestamp": error.timestamp
        })

    def get_errors(self,
                   start_time: Optional[datetime] = None,
                   end_time: Optional[datetime] = None,
                   error_type: Optional[str] = None):
        filtered = self.error_log

        if start_time:
            filtered = [e for e in filtered if e["timestamp"] >= start_time]
        if end_time:
            filtered = [e for e in filtered if e["timestamp"] <= end_time]
        if error_type:
            filtered = [e for e in filtered if e["type"] == error_type]

        return filtered
