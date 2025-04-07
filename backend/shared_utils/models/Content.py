from typing import List
from backend.shared_utils.constants import *

class Content:
    def __init__(
        self,
        id: int,
        text: str,
        is_humorous: bool,
        humor_score: float,
        humor_type: HumorType,
        topics: List[str],
        tone: ToneType,
        emoji_presence: bool,
        text_length: int,
        media_type: MediaType
    ):
        self.id = id
        self.text = text
        self.is_humorous = is_humorous
        self.humor_score = humor_score
        self.humor_type = humor_type
        self.topics = topics
        self.tone = tone
        self.emoji_presence = emoji_presence
        self.text_length = text_length
        self.media_type = media_type
