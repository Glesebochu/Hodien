import 'constants.dart';

class Content {
  final int id;
  final String text;
  final bool isHumorous;
  final double humorScore;
  final HumorType humorType;
  final List<String> topics;
  final ToneType tone;
  final bool emojiPresence;
  final int textLength;
  final MediaType mediaType;

  Content({
    required this.id,
    required this.text,
    required this.isHumorous,
    required this.humorScore,
    required this.humorType,
    required this.topics,
    required this.tone,
    required this.emojiPresence,
    required this.textLength,
    required this.mediaType,
  });
}
