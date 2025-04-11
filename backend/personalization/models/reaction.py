from enum import Enum
from dataclasses import dataclass
from datetime import datetime
from typing import List, Tuple

class ReactionType(Enum):
    NotFunny = "NotFunny"
    Meh = "Meh"
    Funny = "Funny"
    Hilarious = "Hilarious"
    # You can easily extend this enum as the app evolves.

@dataclass
class Reaction:
    reaction_id: str 
    user_id: str
    content_id: str
    reaction_type: ReactionType
    timestamp: datetime

    def get_user_reaction(self) -> Tuple[str, ReactionType, datetime]:
        return (self.content_id, self.reaction_type, self.timestamp)
