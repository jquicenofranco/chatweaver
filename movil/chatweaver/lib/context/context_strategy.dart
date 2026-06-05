import 'package:chatweaver/llm/chat_message.dart';

/// Interfaz Strategy para estrategias de manejo de contexto.
///
/// Dada una lista de mensajes y un budget de tokens, decide quais
/// mensajes se incluyen en la proxima peticion.
///
/// El calculo de tokens se delega al [calculateTokens] provisto
/// — la estrategia NO conoce la tokenizacion especifica del modelo.
abstract class ContextStrategy {
  List<ChatMessage> apply({
    required List<ChatMessage> messages,
    required int budget,
    required int Function(String text) calculateTokens,
  });
}
