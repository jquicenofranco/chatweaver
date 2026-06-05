class SessionNotFoundException implements Exception {
  const SessionNotFoundException(this.sessionId);

  final String sessionId;

  @override
  String toString() => 'SessionNotFoundException: $sessionId';
}
