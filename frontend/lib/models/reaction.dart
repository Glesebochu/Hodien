import 'constants.dart';

class Reaction {
  String reactionId;
  String userId;
  String contentId;
  ReactionType reactionType;
  DateTime timestamp;

  Reaction(
    this.reactionId,
    this.userId,
    this.contentId,
    this.reactionType,
    this.timestamp,
  );

  (String, ReactionType, DateTime) getUserReactions() {
    return (contentId, reactionType, timestamp);
  }
}
