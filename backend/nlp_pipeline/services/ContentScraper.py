import csv
from datetime import datetime
from typing import List

from backend.nlp_pipeline.models.ScrapQuery import ScrapQuery
from backend.shared_utils.models.Post import Post
from backend.shared_utils.models.Comment import Comment

class ContentScraperService:
    def __init__(self, query: ScrapQuery):
        self.query = query

    def get_posts(self, query: ScrapQuery):
        """
        Placeholder: Retrieves raw content data based on the query.
        Returns a list of generic content dicts.
        """
        # Replace this with actual scraping/parsing logic
        return [
            {
                "id": 101,
                "username": "creator1",
                "text": "This cracked me up 😂",
                "likes": 200,
                "reposts": 50,
                "comments": [],
                "sourceURL": "https://example.com/post/101",
                "timestamp": datetime.now()
            },
            {
                "id": 102,
                "username": "creator2",
                "text": "Standard post with no punchline.",
                "likes": 15,
                "reposts": 5,
                "comments": [],
                "sourceURL": "https://example.com/post/102",
                "timestamp": datetime.now()
            }
        ]

    def store_in_csv(self, raw_contents: list):
        """
        Stores the content in a CSV for NLP processing.
        """
        with open('content_data.csv', mode='w', newline='', encoding='utf-8') as file:
            writer = csv.DictWriter(file, fieldnames=[
                "id", "username", "text", "likes", "reposts", "sourceURL", "timestamp"
            ])
            writer.writeheader()
            for item in raw_contents:
                writer.writerow({
                    "id": item["id"],
                    "username": item["username"],
                    "text": item["text"],
                    "likes": item["likes"],
                    "reposts": item["reposts"],
                    "sourceURL": item["sourceURL"],
                    "timestamp": item["timestamp"]
                })

    def create_post_objects(self, raw_contents: list) -> List[Post]:
        """
        Converts raw content dictionaries to Post objects.
        """
        posts = []
        for data in raw_contents:
            post = Post(
                id=data["id"],
                username=data["username"],
                hashtags="",  # Can extract with NLP Using neutral term mapping
                text=data["text"],
                likes=data["likes"],
                retweets=data["reposts"],
                comments=[],
                source_url=data["sourceURL"],
                timestamp=data["timestamp"],
                is_humorous=False,
                humor_score=0.0,
                humor_type=None,
                topics=[],
                tone=None,
                emoji_presence=False,
                text_length=len(data["text"]),
                media_type=None
            )
            posts.append(post)
        return posts

    def create_comment_objects(self, posts: List[Post]) -> List[Comment]:
        """
        Converts post-attached comment data (if available) to Comment objects.
        """
        comments = []
        for post in posts:
            for i, _ in enumerate(post.comments):  # Replace with real comment extraction
                comment = Comment(
                    id=post.id * 100 + i,
                    text=f"Placeholder comment on post {post.id}",
                    main_post=post,
                    is_humorous=False,
                    humor_score=0.0,
                    humor_type=None,
                    topics=[],
                    tone=None,
                    emoji_presence=False,
                    text_length=0,
                    media_type=None
                )
                comments.append(comment)
        return comments
