// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ChatWeaver';

  @override
  String get modelSelectorTitle => 'Choose a model';

  @override
  String get modelSelectorEmpty => 'No enabled models. Tap Settings.';

  @override
  String get modelSelectorGoToSettings => 'Go to Settings';

  @override
  String modelSelectorSubtitle(String contextWindow, String streaming) {
    return '$contextWindow • $streaming';
  }

  @override
  String get modelSelectorStreaming => 'streaming';

  @override
  String get modelSelectorBadgeFree => 'free';

  @override
  String get modelSelectorBadgePaid => 'paid';

  @override
  String get modelSelectorDisable => 'Disable';

  @override
  String get tokenInputTitle => 'Your API key';

  @override
  String tokenInputProvider(String provider) {
    return 'Provider: $provider';
  }

  @override
  String tokenInputModel(String model) {
    return 'Model: $model';
  }

  @override
  String get tokenInputLabel => 'Paste your API key';

  @override
  String get tokenInputRemember => 'Remember token';

  @override
  String get tokenInputSubmit => 'Test and continue';

  @override
  String get tokenInputHelp => 'Where do I get my token?';

  @override
  String get tokenInputConnecting => 'Connecting…';

  @override
  String get tokenInputConnected => 'Connected';

  @override
  String get sessionsTitle => 'Sessions';

  @override
  String get sessionsEmpty => 'Start your first conversation';

  @override
  String get sessionsNewSession => 'New session';

  @override
  String get sessionsRename => 'Rename';

  @override
  String get sessionsDelete => 'Delete';

  @override
  String get sessionsDeleteConfirmTitle => 'Delete session?';

  @override
  String get sessionsDeleteConfirmBody => 'This action cannot be undone.';

  @override
  String get sessionsCancel => 'Cancel';

  @override
  String get sessionsConfirm => 'Delete';

  @override
  String sessionsLastMessageAgo(String when) {
    return '$when ago';
  }

  @override
  String sessionsTokens(int count) {
    return '$count tokens';
  }

  @override
  String get chatStop => 'Stop';

  @override
  String get chatPlaceholder => 'Type your message…';

  @override
  String get chatSend => 'Send';

  @override
  String get chatRename => 'Rename session';

  @override
  String get chatSetSystemPrompt => 'System prompt';

  @override
  String get chatDeleteSession => 'Delete session';

  @override
  String chatContextOverflow(int n) {
    return 'Discarded $n old messages';
  }

  @override
  String chatTokensUsed(int used, int budget) {
    return '$used / $budget';
  }

  @override
  String chatProjectedWarning(int pct) {
    return 'Next message will use $pct% of context';
  }

  @override
  String get chatRetry => 'Retry';

  @override
  String get chatMessageFailed => 'Send failed';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsCredentials => 'Credentials';

  @override
  String get settingsModels => 'Models';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAddCredential => 'Add credential';

  @override
  String get settingsNoCredentials => 'No credentials saved';

  @override
  String get settingsEditCredential => 'Edit credential';

  @override
  String get settingsDeleteCredential => 'Delete credential';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLangEs => 'Spanish';

  @override
  String get settingsLangEn => 'English';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonClose => 'Close';
}
