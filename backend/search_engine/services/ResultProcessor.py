
class ResultProcessor:
    def sort_by_final_rank(self, documents: list["ProfileMatchedDocument"]) -> list["ProfileMatchedDocument"]: # type: ignore
        """
        Sorts documents based on profile_match_score if available, otherwise global_rank.
        Returns a new list sorted descending.
        """
        return sorted(
            documents,
            key=lambda doc: doc.profile_match_score if doc.profile_match_score is not None else doc.global_rank,
            reverse=True
        )

    def filter_weak_results(self, documents: list["ProfileMatchedDocument"], threshold: float) -> list["ProfileMatchedDocument"]: # type: ignore
        """
        Filters out documents below the score threshold.
        Uses the same logic as sorting: prefers profile_match_score if present.
        """
        return [
            doc for doc in documents
            if (doc.profile_match_score if doc.profile_match_score is not None else doc.global_rank) >= threshold
        ]

    def pass_content_to_view(self, documents: list["ProfileMatchedDocument"]) -> list["FeedContent"]: # type: ignore
        """
        Extracts content IDs and ranks, passes them to ContentProvider to fetch the actual content.
        """
        id_score_pairs = [
            {
                "id": doc.id,
                "score": doc.profile_match_score if doc.profile_match_score is not None else doc.global_rank
            }
            for doc in documents
        ]
        return self._fetch_content_from_provider(id_score_pairs)

    # ------------------------------------------------------------
    # Internal Placeholder Logic
    # ------------------------------------------------------------

    def _fetch_content_from_provider(self, id_score_pairs: list[dict]) -> list["Content"]: # type: ignore
        """
        Placeholder: Calls ContentProvider.pass_content_to_view().
        Replace with actual service integration.
        """
        print(f"[Stub] Fetching content for IDs: {[entry['id'] for entry in id_score_pairs]}")
        return []  # Replace with real feed content objects
