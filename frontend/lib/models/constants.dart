enum HumorType {
  physical('Physical'),
  linguistic('Linguistic'),
  situational('Situational'),
  critical('Critical');

  final String value;
  const HumorType(this.value);
}

enum ToneType {
  positive('Positive'),
  neutral('Neutral'),
  negative('Negative');

  final String value;
  const ToneType(this.value);
}

enum MediaType {
  textOnly('TextOnly'),
  image('Image'),
  video('Video');

  final String value;
  const MediaType(this.value);
}

enum ReactionType {
  notFunny('NotFunny'),
  meh('Meh'),
  funny('Funny'),
  hillarious('Hilarious');

  final String value;
  const ReactionType(this.value);
}
