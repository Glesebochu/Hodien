class Favorite {
  final String userId;
  final List<String> contentIds;
  final DateTime favoritedAt;

  Favorite({
    required this.userId,
    required this.contentIds,
    required this.favoritedAt,
  });

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {'userId': userId, 'contentIds': contentIds};
  }
}
