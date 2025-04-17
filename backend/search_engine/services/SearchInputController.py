# class SearchInputController:
#     def __init__(self):
#         self.translator = Translator() # type: ignore
#         self.preprocessor = DataPreprocessor() # type: ignore

#     def handle_user_query(self, user_input: str, user_id: str, source: str) -> "UserQuery": # type: ignore
#         """
#         Main coordinator: translates, creates, preprocesses, updates, and returns the UserQuery.
#         """
#         result = self._perform_translation_logic(user_input)
#         query = self._perform_query_creation_logic(user_input, result, user_id, source)
#         enriched_data = self._perform_preprocessing_logic(query.translated)
#         self._perform_update_logic(query, enriched_data)

#         return query

#     # ------------------------------------------------------------
#     # Internal Placeholder Logic (Stubs for real implementations)
#     # ------------------------------------------------------------

#     def _perform_translation_logic(self, user_input: str) -> dict:
#         """
#         Placeholder: Simulate translation result.
#         Replace this with Translator logic or call to external API.
#         """
#         return self.translator.translate_and_detect(user_input)

#     def _perform_query_creation_logic(self, original: str, result: dict, user_id: str, source: str) -> "UserQuery": # type: ignore
#         """
#         Placeholder: Construct the UserQuery object.
#         Extend this to handle duplicate detection or advanced metadata.
#         """
#         return UserQuery( # type: ignore
#             original=original,
#             translated=result["translated_text"],
#             language=result["language"],
#             user_id=user_id,
#             source=source
#         )

#     def _perform_preprocessing_logic(self, translated_text: str) -> dict:
#         """
#         Placeholder: Run through NLP preprocessing.
#         You can later enrich this with conditional logic, advanced models, or caching.
#         """
#         return self.preprocessor.preprocess(translated_text)

#     def _perform_update_logic(self, query: "UserQuery", enriched_data: dict): # type: ignore
#         """
#         Placeholder: Apply enrichment to the query object.
#         This could later include logging, profile update hooks, or validation.
#         """
#         query.update(enriched_data)
# 1. Accept user query with its input data including translation

# 2. Validate the query before object creation

#  3. Create the query object only if the query is valid