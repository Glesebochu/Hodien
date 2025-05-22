from typing import List
from backend.shared_utils.constants import *

class Content:
    def __init__(
        self,
        id: int,
        text: str,
        is_humorous: bool = False,
        humor_score: float = 0.0,
        humor_type: HumorType = None,
        topics: List[str] = None,
        tone: ToneType = None,
        emoji_presence: bool = False,
        text_length: int = 0,
        media_type: MediaType = None
    ):
        self.id = id
        self.text = text
        self.is_humorous = is_humorous
        self.humor_score = humor_score
        self.humor_type = humor_type
        self.topics = topics or []
        self.tone = tone
        self.emoji_presence = emoji_presence
        self.text_length = text_length
        self.media_type = media_type
