from typing import List, Dict

# Simulated FavoriteItem structure
class FavoriteItem:
    def __init__(self, post_id: str):
        self.post_id = post_id

    def __repr__(self):
        return f"FavoriteItem(post_id='{self.post_id}')"


class FavoritesService:
    def __init__(self):
        # Maps user_id to a list of favorite post_ids
        self.user_favorites: Dict[str, List[str]] = {}

    def save_post_to_favorites(self, user_id: str, post_id: str) -> bool:
        if user_id not in self.user_favorites:
            self.user_favorites[user_id] = []

        if post_id not in self.user_favorites[user_id]:
            self.user_favorites[user_id].append(post_id)
            print(f"Post {post_id} saved to {user_id}'s favorites.")
            return True

        print(f"Post {post_id} was already in {user_id}'s favorites.")
        return False

    def check_if_already_favorited(self, user_id: str, post_id: str) -> bool:
        return post_id in self.user_favorites.get(user_id, [])

    def remove_post_from_favorites(self, user_id: str, post_id: str) -> bool:
        if user_id in self.user_favorites and post_id in self.user_favorites[user_id]:
            self.user_favorites[user_id].remove(post_id)
            print(f"Post {post_id} removed from {user_id}'s favorites.")
            return True

        print(f"Post {post_id} not found in {user_id}'s favorites.")
        return False

    def get_user_favorites(self, user_id: str) -> List[FavoriteItem]:
        favorites = self.user_favorites.get(user_id, [])
        return [FavoriteItem(pid) for pid in favorites]
