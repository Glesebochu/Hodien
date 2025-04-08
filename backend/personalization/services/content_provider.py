from dataclasses import dataclass, field
from typing import List

@dataclass
class ContentItem:
    id: str
    content: str
    category: str

@dataclass
class UserProfile:
    user_id: str
    preferred_humor_types: List[str]

@dataclass
class ContentProvider:
    user_profile: UserProfile
    content_pool: List[ContentItem]
    algorithm: str = "basic"

    def generate_content(self) -> List[ContentItem]:
        # Simulated recommendation logic based on preferred humor types
        recommendations = [
            item for item in self.content_pool
            if item.category in self.user_profile.preferred_humor_types
        ]
        print("Generated personalized content.")
        return recommendations

    def adjust_recommendations(self, user_feedback):
        # Placeholder for algorithm adjustment based on feedback
        print(f"Adjusting recommendations based on feedback: {user_feedback}")
        self.algorithm = "adjusted_based_on_feedback"

    def generate_surprise_content(self) -> List[ContentItem]:
        surprise_content = [
            item for item in self.content_pool
            if item.category not in self.user_profile.preferred_humor_types
        ]
        print("Generated surprise content.")
        return surprise_content

    def pass_content_to_view(self, content_ids: List[str]):
        # Just a stub to represent pushing data to the frontend
        selected_content = [
            item for item in self.content_pool if item.id in content_ids
        ]
        print(f"Passing content to view: {[item.id for item in selected_content]}")
        return selected_content
