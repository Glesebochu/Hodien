import 'post.dart';
import 'content.dart';

class Comment extends Content {
  final Post mainPost;

  Comment({
    required super.id,
    required super.text,
    required this.mainPost,
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
