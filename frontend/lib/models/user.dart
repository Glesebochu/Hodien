class User {
  final String userId;
  final String username;
  final String email;
  final String status;

  User({
    required this.userId,
    required this.username,
    required this.email,
    this.status = 'active',
  });

  // Create a User from a Firestore document
  factory User.fromFirestore(Map<String, dynamic> data, String id) {
    return User(
      userId: id,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      status: data['status'] ?? 'active',
    );
  }

  // Convert User to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {'username': username, 'email': email, 'status': status};
  }
}

  // void editAccount(User updatedUser) {
  //   username = updatedUser.username;
  //   email = updatedUser.email;
  // }

  // void removeAccount() {
  //   status = "deleted";
  // }

  // String getUsername() {
  //   return username;
  // }