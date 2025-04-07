class CustomError extends Error {
  final DateTime timestamp;
  final String message;

  CustomError(this.message) : timestamp = DateTime.now();

  @override
  String toString() => '$message (Occurred at: $timestamp)';
}
