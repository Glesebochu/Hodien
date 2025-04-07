import 'content.dart';
import 'comment.dart';

class Post extends Content {
  final String username;
  final String hashtags;
  final int likes;
  final int retweets;
  final List<Comment> comments;
  final String sourceURL;
  final DateTime timestamp;

  Post({
    required super.id,
    required this.username,
    required this.hashtags,
    required super.text,
    required this.likes,
    required this.retweets,
    required this.comments,
    required this.sourceURL,
    required this.timestamp,
    required super.isHumorous,
    required super.humorScore,
    required super.humorType,
    required super.topics,
    required super.tone,
    required super.emojiPresence,
    required super.textLength,
    required super.mediaType,
  });
}
