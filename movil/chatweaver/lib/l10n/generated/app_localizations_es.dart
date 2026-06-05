// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ChatWeaver';

  @override
  String get modelSelectorTitle => 'Elegi un modelo';

  @override
  String get modelSelectorEmpty => 'No hay modelos habilitados. Toca Ajustes.';

  @override
  String get modelSelectorGoToSettings => 'Ir a Ajustes';

  @override
  String modelSelectorSubtitle(String contextWindow, String streaming) {
    return '$contextWindow • $streaming';
  }

  @override
  String get modelSelectorStreaming => 'streaming';

  @override
  String get modelSelectorBadgeFree => 'gratis';

  @override
  String get modelSelectorBadgePaid => 'pago';

  @override
  String get modelSelectorDisable => 'Deshabilitar';

  @override
  String get tokenInputTitle => 'Tu API key';

  @override
  String tokenInputProvider(String provider) {
    return 'Proveedor: $provider';
  }

  @override
  String tokenInputModel(String model) {
    return 'Modelo: $model';
  }

  @override
  String get tokenInputLabel => 'Pega tu API key';

  @override
  String get tokenInputRemember => 'Recordar token';

  @override
  String get tokenInputSubmit => 'Probar y continuar';

  @override
  String get tokenInputHelp => 'Donde consigo mi token?';

  @override
  String get tokenInputConnecting => 'Conectando…';

  @override
  String get tokenInputConnected => 'Conectado';

  @override
  String get sessionsTitle => 'Sesiones';

  @override
  String get sessionsEmpty => 'Empeza tu primera conversacion';

  @override
  String get sessionsNewSession => 'Nueva sesion';

  @override
  String get sessionsRename => 'Renombrar';

  @override
  String get sessionsDelete => 'Borrar';

  @override
  String get sessionsDeleteConfirmTitle => 'Borrar sesion?';

  @override
  String get sessionsDeleteConfirmBody => 'Esta accion no se puede deshacer.';

  @override
  String get sessionsCancel => 'Cancelar';

  @override
  String get sessionsConfirm => 'Borrar';

  @override
  String sessionsLastMessageAgo(String when) {
    return 'hace $when';
  }

  @override
  String sessionsTokens(int count) {
    return '$count tokens';
  }

  @override
  String get chatStop => 'Detener';

  @override
  String get chatPlaceholder => 'Escribi tu mensaje…';

  @override
  String get chatSend => 'Enviar';

  @override
  String get chatRename => 'Renombrar sesion';

  @override
  String get chatSetSystemPrompt => 'Prompt del sistema';

  @override
  String get chatDeleteSession => 'Borrar sesion';

  @override
  String chatContextOverflow(int n) {
    return 'Se descartaron $n mensajes antiguos';
  }

  @override
  String chatTokensUsed(int used, int budget) {
    return '$used / $budget';
  }

  @override
  String chatProjectedWarning(int pct) {
    return 'Proximo mensaje usara $pct% del contexto';
  }

  @override
  String get chatRetry => 'Reintentar';

  @override
  String get chatMessageFailed => 'Error al enviar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsCredentials => 'Credenciales';

  @override
  String get settingsModels => 'Modelos';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsAdvanced => 'Avanzado';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAddCredential => 'Agregar credencial';

  @override
  String get settingsNoCredentials => 'Sin credenciales guardadas';

  @override
  String get settingsEditCredential => 'Editar credencial';

  @override
  String get settingsDeleteCredential => 'Borrar credencial';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Claro';

  @override
  String get settingsThemeDark => 'Oscuro';

  @override
  String get settingsLangEs => 'Espanol';

  @override
  String get settingsLangEn => 'Ingles';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonConfirm => 'Confirmar';

  @override
  String get commonDelete => 'Borrar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonClose => 'Cerrar';
}
