import random
from backend.shared_utils.constants import *

class ContentHumorAnalyzer:
    def classify_content(self, contents: list):
        for content in contents:
            # Placeholder classification logic:
            keywords = ['funny', 'joke', 'lol', '😂', 'hilarious']
            is_humorous = any(k in content.text.lower() for k in keywords)
            humor_score = random.uniform(0, 10) if is_humorous else random.uniform(0, 3)

            content.is_humorous = is_humorous
            content.humor_score = round(humor_score, 2)

    def extract_metadata(self, contents: list):
        for content in contents:
            # Assign humor_type based on keyword match
            if 'slip' in content.text.lower():
                content.humor_type = HumorType.PHYSICAL
            elif 'pun' in content.text.lower():
                content.humor_type = HumorType.LINGUISTIC
            elif 'awkward' in content.text.lower():
                content.humor_type = HumorType.SITUATIONAL
            elif 'roast' in content.text.lower():
                content.humor_type = HumorType.CRITICAL
            else:
                content.humor_type = HumorType.SITUATIONAL  # Default

            # Assign topics (very simple token pick)
            content.topics = list(set(word.lower() for word in content.text.split() if len(word) > 4))[:3]

            # Tone estimation
            if any(w in content.text.lower() for w in ['great', 'awesome', 'love']):
                content.tone = ToneType.POSITIVE
            elif any(w in content.text.lower() for w in ['bad', 'hate', 'awful']):
                content.tone = ToneType.NEGATIVE
            else:
                content.tone = ToneType.NEUTRAL

            # Emoji presence
            content.emoji_presence = any(c in content.text for c in ['😂', '😊', '😡', '😭'])

            # Text length
            content.text_length = len(content.text)

            # Media type based on fake guess (you'd normally check actual fields)
            if "http" in content.text and ".mp4" in content.text:
                content.media_type = MediaType.VIDEO
            elif "http" in content.text and (".jpg" in content.text or ".png" in content.text):
                content.media_type = MediaType.IMAGE
            else:
                content.media_type = MediaType.TEXT_ONLY
