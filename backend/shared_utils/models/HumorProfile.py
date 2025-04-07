from backend.nlp_pipeline.models import ScrapQuery
from backend.shared_utils.constants import ReactionType

class HumorProfile:
    def __init__(self, user_id, interests=None):
        self.user_id = user_id
        self.interests = interests or []
        self.physical_humor_preference = 0.0
        self.linguistic_humor_preference = 0.0
        self.situational_humor_preference = 0.0
        self.critical_humor_preference = 0.0
        self.reaction_history = []
        self.favorite_content = []

    def set_preferences_from_test(self, answers):
        self.physical_humor_preference = answers.get("physical", 0.0)
        self.linguistic_humor_preference = answers.get("linguistic", 0.0)
        self.situational_humor_preference = answers.get("situational", 0.0)
        self.critical_humor_preference = answers.get("critical", 0.0)

    def get_user_preferences(self):
        return {
            "physical": round(self.physical_humor_preference, 2),
            "linguistic": round(self.linguistic_humor_preference, 2),
            "situational": round(self.situational_humor_preference, 2),
            "critical": round(self.critical_humor_preference, 2),
        }

    def update_from_reaction(self, reaction: 'Reaction', profile: 'HumorProfile') -> 'HumorProfile':
        boost_map = {
            ReactionType.NOT_FUNNY: -0.1,
            ReactionType.MEH: 0.0,
            ReactionType.FUNNY: 0.2,
            ReactionType.HILLARIOUS: 0.4,
        }

        content = self._find_content_by_id(reaction.content_id)
        if not content:
            return profile

        delta = boost_map.get(reaction.reaction_type, 0.0)

        if content.humor_type.name == "PHYSICAL":
            profile.physical_humor_preference += delta
        elif content.humor_type.name == "LINGUISTIC":
            profile.linguistic_humor_preference += delta
        elif content.humor_type.name == "SITUATIONAL":
            profile.situational_humor_preference += delta
        elif content.humor_type.name == "CRITICAL":
            profile.critical_humor_preference += delta

        profile.reaction_history.append(reaction)
        return profile

    def update_from_query(self, query: ScrapQuery, profile: 'HumorProfile') -> 'HumorProfile':
        text = query.textContains.lower()
        if "physical" in text:
            profile.physical_humor_preference += 0.05
        if "linguistic" in text:
            profile.linguistic_humor_preference += 0.05
        if "situational" in text:
            profile.situational_humor_preference += 0.05
        if "critical" in text:
            profile.critical_humor_preference += 0.05
        return profile

    def save_profile(self, profile: 'HumorProfile') -> bool:
        try:
            # Insert saving logic here (file, DB, etc.)
            return True
        except:
            return False

    def _find_content_by_id(self, content_id):
        for content in self.favorite_content:
            if content.id == content_id:
                return content
        return None
