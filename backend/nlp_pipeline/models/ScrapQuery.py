class ScrapQuery:
    def __init__(self, username="", hashtags="", mustContain="", canContain="", minLikes=0, minReposts=0, language="", fromDate=None, toDate=None):
        self.username = username
        self.hashtags = hashtags
        self.mustContain = mustContain
        self.canContain = canContain
        self.minLikes = minLikes
        self.minReposts = minReposts
        self.language = language
        self.fromDate = fromDate
        self.toDate = toDate

    def getQuery(self):
        query_parts = []

        # Add username
        if self.username:
            query_parts.append(f"from:{self.username}")

        # Add hashtags
        if self.hashtags:
            hashtags_query = " OR ".join([f"#{tag}" for tag in self.hashtags])
            query_parts.append(f"({hashtags_query})")

        # Add mustContain keywords
        if self.mustContain:
            must_query = " ".join(self.mustContain)
            query_parts.append(f"({must_query})")

        # Add canContain keywords
        if self.canContain:
            can_query = " OR ".join(self.canContain)
            query_parts.append(f"({can_query})")

        # Add minimum likes
        if self.minLikes:
            query_parts.append(f"min_faves:{self.minLikes}")

        # Add minimum reposts
        if self.minReposts:
            query_parts.append(f"min_retweets:{self.minReposts}")

        # Add language
        if self.language:
            query_parts.append(f"lang:{self.language}")

        # Add date range
        if self.fromDate and self.toDate:
            query_parts.append(f"since:{self.fromDate} until:{self.toDate}")

        # Combine all parts into a single query string
        query = " ".join(query_parts)
        return query