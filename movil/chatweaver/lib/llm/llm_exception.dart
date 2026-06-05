/// Jerarquia sellada de excepciones del modulo LLM.
///
/// [userMessage] es legible para el usuario. La libreria HTTP
/// nunca se filtra fuera del modulo.
sealed class LlmException implements Exception {
  const LlmException(this.userMessage);

  final String userMessage;

  @override
  String toString() => '$runtimeType: $userMessage';
}

class NetworkException extends LlmException {
  const NetworkException(super.userMessage);
}

class AuthException extends LlmException {
  const AuthException(super.userMessage);
}

class ContextWindowExceededException extends LlmException {
  const ContextWindowExceededException(super.userMessage);
}

class RateLimitException extends LlmException {
  const RateLimitException(super.userMessage);
}

class ProviderException extends LlmException {
  const ProviderException(super.userMessage);
}

class TimeoutException extends LlmException {
  const TimeoutException(super.userMessage);
}
