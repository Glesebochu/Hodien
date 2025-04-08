class User {
  String userId;
  String username;
  String email;
  String passwordHash;
  String status;

  User(
    this.userId,
    this.username,
    this.email,
    this.passwordHash, {
    this.status = "active",
  });

  void editAccount(User updatedUser) {
    username = updatedUser.username;
    email = updatedUser.email;
  }

  void removeAccount() {
    status = "deleted";
  }

  String getUsername() {
    return username;
  }
}
