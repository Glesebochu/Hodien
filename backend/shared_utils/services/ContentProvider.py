from dataclasses import dataclass
from typing import List
from models.User import user
from models.Content import content

# Take query and profile as input then match the indexed documents to the profile only and to both
# Extract feed_content_pool and personalized_search_content_pool
@dataclass
class ContentProvider:
    user_profile: user
    content_pool: List[content]

    def generate_content(self) -> List[content]:
        # Recommend items matching user’s preferred humor types
        recommendations = [
            item for item in self.content_pool
            if item.category in self.user_profile.preferred_humor_types
        ]
        print("Generated personalized content.")
        return recommendations

    def adjust_recommendations(self, user_reaction):
        # Feedback logic can be expanded in the future
        print(f"Adjusting recommendations based on reaction: {user_reaction}")

    def generate_surprise_content(self) -> List[content]:
        # Recommend content outside user preferences
        surprise_content = [
            item for item in self.content_pool
            if item.category not in self.user_profile.preferred_humor_types
        ]
        print("Generated surprise content.")
        return surprise_content

    def pass_content_to_view(self, content_ids: List[str]):
        # Return content items by ID
        selected_content = [
            item for item in self.content_pool if item.id in content_ids
        ]
        print(f"Passing content to view: {[item.id for item in selected_content]}")
        return selected_content
