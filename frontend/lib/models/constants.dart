enum HumorType {
  Physical('Physical'),
  Linguistic('Linguistic'),
  Situational('Situational'),
  Critical('Critical');

  final String value;
  const HumorType(this.value);
}

enum ToneType {
  Positive('Positive'),
  Neutral('Neutral'),
  Negative('Negative');

  final String value;
  const ToneType(this.value);
}

enum MediaType {
  TextOnly('TextOnly'),
  Image('Image'),
  Video('Video');

  final String value;
  const MediaType(this.value);
}
