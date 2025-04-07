from enum import Enum

class HumorType(Enum):
    PHYSICAL = "Physical"
    LINGUISTIC = "Linguistic"
    SITUATIONAL = "Situational"
    CRITICAL = "Critical"

class ToneType(Enum):
    POSITIVE = "Positive"
    NEUTRAL = "Neutral"
    NEGATIVE = "Negative"

class MediaType(Enum):
    TEXT_ONLY = "TextOnly"
    IMAGE = "Image"
    VIDEO = "Video"