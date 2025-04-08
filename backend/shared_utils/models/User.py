class User:
    def __init__(self, user_id, username, email, password_hash, status="active"):
        self.user_id = user_id
        self.username = username
        self.email = email
        self.password_hash = password_hash
        self.status = status

    def edit_account(self, updated_user):
        self.username = updated_user.username
        self.email = updated_user.email

    def remove_account(self):
        self.status = "deleted"

    def get_username(self):
        return self.username