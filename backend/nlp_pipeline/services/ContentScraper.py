from typing import List

from twikit import Client, TooManyRequests
import time
from datetime import datetime
import csv
from random import randint
import os

import sys
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from ..models.ScrapQuery import ScrapQuery
from ....backend.shared_utils.models.Post import Post
from ....backend.shared_utils.models.Comment import Comment
# from backend.shared_utils.models.Post import Post
# from backend.shared_utils.models.Comment import Comment

class ContentScraperService:
    def __init__(self, query: ScrapQuery):
        self.query = query
        
    # QUERY = '(lol OR rofl OR 🤣 OR hilarious) min_replies:100 min_faves:5000 min_retweets:5000'

    async def get_tweets(self, tweets):
        if tweets is None:
            print(f'{datetime.now()} - Getting tweets...')
            tweets = await client.search_tweet(self.query.getQuery(), product='Top')
        else:
            wait_time = randint(7, 12)
            print(f'{datetime.now()} - Getting next tweets after {wait_time} seconds ...')
            time.sleep(wait_time)
            tweets = await tweets.next()

        return tweets


    async def main(self, min_tweets=30):

        if not os.path.exists('posts.csv'):
            with open('posts.csv', 'w', newline='', encoding='utf-8') as file:
                writer = csv.writer(file)
                writer.writerow(['Tweet_count', 'Username', 'Text', 'Created At', 'Retweets', 'Likes', 'Id'])
        
        global tweet_count  # Declare tweet_count as global to access and modify it
        global tweets
        global client

        client = Client(language='en-US')
        client.load_cookies('cookies.json')

        tweet_count = 0
        tweets = None
        
        round_no = 1
        
        while tweet_count < min_tweets:
            try:
                tweets = await self.get_tweets(self, tweets)
            except TooManyRequests as e:
                rate_limit_reset = datetime.fromtimestamp(e.rate_limit_reset)
                print(f'{datetime.now()} - Rate limit reached. Waiting until {rate_limit_reset}')
                wait_time = rate_limit_reset - datetime.now()
                time.sleep(wait_time.total_seconds())
                continue

            if not tweets:
                print(f'{datetime.now()} - No more tweets found')
                break

            self.store_in_csv(tweets)

            print(f'{datetime.now()} - Got {tweet_count} tweets on round {round_no}')
            round_no+=1
            
        print(f'{datetime.now()} - Done! {tweet_count} tweets found')

        

    def store_in_csv(self, tweets):
        """
        Stores the content in a CSV for NLP processing.
        """
        for tweet in tweets:
            tweet_count += 1
            tweet_data = [tweet_count, tweet.user.name, tweet.text, tweet.created_at, tweet.retweet_count, tweet.favorite_count, tweet.id]
            
            with open('posts.csv', 'a', newline='', encoding='utf-8') as file:
                writer = csv.writer(file)
                writer.writerow(tweet_data)

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


# Run the main function
if __name__ == "__main__":
    import asyncio
    query = ScrapQuery(
        keywords=["lol", "rofl", "🤣", "hilarious"],
        min_replies=100,
        min_faves=5000,
        min_retweets=5000,
        language="en",
        since=None,  # Add a specific date if needed, e.g., "2023-01-01"
        until=None   # Add a specific date if needed, e.g., "2023-12-31"
    )
    scraper = ContentScraperService(query=query)
    
    asyncio.run(scraper.main())