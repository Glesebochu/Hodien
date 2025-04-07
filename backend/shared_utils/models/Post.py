from backend.shared_utils.models import Content

class Post(Content):
    def __init__(self, id, username, hashtags, text, likes, retweets, comments, source_url, timestamp, **kwargs):
        super().__init__(id=id, text=text, **kwargs)
        self.username = username
        self.hashtags = hashtags
        self.likes = likes
        self.retweets = retweets
        self.comments = comments  # List of Comment
        self.source_url = source_url
        self.timestamp = timestamp