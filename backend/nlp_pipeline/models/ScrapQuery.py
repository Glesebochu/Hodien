class ScrapQuery:
    def __init__(self, username="", hashtags="", textContains="", minLikes=0, minReposts=0):
        self.username = username
        self.hashtags = hashtags
        self.textContains = textContains
        self.minLikes = minLikes
        self.minReposts = minReposts

    def getQuery(self):
        query_parts = []

        if self.username:
            query_parts.append(f"from:{self.username}")
        if self.hashtags:
            for tag in self.hashtags.split():
                query_parts.append(f"#{tag}")
        if self.textContains:
            query_parts.append(f'"{self.textContains}"')
        if self.minLikes > 0:
            query_parts.append(f"min_faves:{self.minLikes}")
        if self.minReposts > 0:
            query_parts.append(f"min_retweets:{self.minReposts}")

        return " ".join(query_parts)
