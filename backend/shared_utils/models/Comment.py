from backend.shared_utils.models import Content

class Comment(Content):
    def __init__(self, id, text, main_post, **kwargs):
        super().__init__(id=id, text=text, **kwargs)
        self.main_post = main_post