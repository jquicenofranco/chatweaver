import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// Titulo de la app
  ///
  /// In es, this message translates to:
  /// **'ChatWeaver'**
  String get appTitle;

  /// No description provided for @modelSelectorTitle.
  ///
  /// In es, this message translates to:
  /// **'Elegi un modelo'**
  String get modelSelectorTitle;

  /// No description provided for @modelSelectorEmpty.
  ///
  /// In es, this message translates to:
  /// **'No hay modelos habilitados. Toca Ajustes.'**
  String get modelSelectorEmpty;

  /// No description provided for @modelSelectorGoToSettings.
  ///
  /// In es, this message translates to:
  /// **'Ir a Ajustes'**
  String get modelSelectorGoToSettings;

  /// No description provided for @modelSelectorSubtitle.
  ///
  /// In es, this message translates to:
  /// **'{contextWindow} • {streaming}'**
  String modelSelectorSubtitle(String contextWindow, String streaming);

  /// No description provided for @modelSelectorStreaming.
  ///
  /// In es, this message translates to:
  /// **'streaming'**
  String get modelSelectorStreaming;

  /// No description provided for @modelSelectorBadgeFree.
  ///
  /// In es, this message translates to:
  /// **'gratis'**
  String get modelSelectorBadgeFree;

  /// No description provided for @modelSelectorBadgePaid.
  ///
  /// In es, this message translates to:
  /// **'pago'**
  String get modelSelectorBadgePaid;

  /// No description provided for @modelSelectorDisable.
  ///
  /// In es, this message translates to:
  /// **'Deshabilitar'**
  String get modelSelectorDisable;

  /// No description provided for @tokenInputTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu API key'**
  String get tokenInputTitle;

  /// No description provided for @tokenInputProvider.
  ///
  /// In es, this message translates to:
  /// **'Proveedor: {provider}'**
  String tokenInputProvider(String provider);

  /// No description provided for @tokenInputModel.
  ///
  /// In es, this message translates to:
  /// **'Modelo: {model}'**
  String tokenInputModel(String model);

  /// No description provided for @tokenInputLabel.
  ///
  /// In es, this message translates to:
  /// **'Pega tu API key'**
  String get tokenInputLabel;

  /// No description provided for @tokenInputRemember.
  ///
  /// In es, this message translates to:
  /// **'Recordar token'**
  String get tokenInputRemember;

  /// No description provided for @tokenInputSubmit.
  ///
  /// In es, this message translates to:
  /// **'Probar y continuar'**
  String get tokenInputSubmit;

  /// No description provided for @tokenInputHelp.
  ///
  /// In es, this message translates to:
  /// **'Donde consigo mi token?'**
  String get tokenInputHelp;

  /// No description provided for @tokenInputConnecting.
  ///
  /// In es, this message translates to:
  /// **'Conectando…'**
  String get tokenInputConnecting;

  /// No description provided for @tokenInputConnected.
  ///
  /// In es, this message translates to:
  /// **'Conectado'**
  String get tokenInputConnected;

  /// No description provided for @sessionsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sesiones'**
  String get sessionsTitle;

  /// No description provided for @sessionsEmpty.
  ///
  /// In es, this message translates to:
  /// **'Empeza tu primera conversacion'**
  String get sessionsEmpty;

  /// No description provided for @sessionsNewSession.
  ///
  /// In es, this message translates to:
  /// **'Nueva sesion'**
  String get sessionsNewSession;

  /// No description provided for @sessionsRename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get sessionsRename;

  /// No description provided for @sessionsDelete.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get sessionsDelete;

  /// No description provided for @sessionsDeleteConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Borrar sesion?'**
  String get sessionsDeleteConfirmTitle;

  /// No description provided for @sessionsDeleteConfirmBody.
  ///
  /// In es, this message translates to:
  /// **'Esta accion no se puede deshacer.'**
  String get sessionsDeleteConfirmBody;

  /// No description provided for @sessionsCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get sessionsCancel;

  /// No description provided for @sessionsConfirm.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get sessionsConfirm;

  /// No description provided for @sessionsLastMessageAgo.
  ///
  /// In es, this message translates to:
  /// **'hace {when}'**
  String sessionsLastMessageAgo(String when);

  /// No description provided for @sessionsTokens.
  ///
  /// In es, this message translates to:
  /// **'{count} tokens'**
  String sessionsTokens(int count);

  /// No description provided for @chatStop.
  ///
  /// In es, this message translates to:
  /// **'Detener'**
  String get chatStop;

  /// No description provided for @chatPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Escribi tu mensaje…'**
  String get chatPlaceholder;

  /// No description provided for @chatSend.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get chatSend;

  /// No description provided for @chatRename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar sesion'**
  String get chatRename;

  /// No description provided for @chatSetSystemPrompt.
  ///
  /// In es, this message translates to:
  /// **'Prompt del sistema'**
  String get chatSetSystemPrompt;

  /// No description provided for @chatDeleteSession.
  ///
  /// In es, this message translates to:
  /// **'Borrar sesion'**
  String get chatDeleteSession;

  /// No description provided for @chatContextOverflow.
  ///
  /// In es, this message translates to:
  /// **'Se descartaron {n} mensajes antiguos'**
  String chatContextOverflow(int n);

  /// No description provided for @chatTokensUsed.
  ///
  /// In es, this message translates to:
  /// **'{used} / {budget}'**
  String chatTokensUsed(int used, int budget);

  /// No description provided for @chatProjectedWarning.
  ///
  /// In es, this message translates to:
  /// **'Proximo mensaje usara {pct}% del contexto'**
  String chatProjectedWarning(int pct);

  /// No description provided for @chatRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get chatRetry;

  /// No description provided for @chatMessageFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar'**
  String get chatMessageFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsCredentials.
  ///
  /// In es, this message translates to:
  /// **'Credenciales'**
  String get settingsCredentials;

  /// No description provided for @settingsModels.
  ///
  /// In es, this message translates to:
  /// **'Modelos'**
  String get settingsModels;

  /// No description provided for @settingsAppearance.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsAdvanced.
  ///
  /// In es, this message translates to:
  /// **'Avanzado'**
  String get settingsAdvanced;

  /// No description provided for @settingsAbout.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get settingsAbout;

  /// No description provided for @settingsAddCredential.
  ///
  /// In es, this message translates to:
  /// **'Agregar credencial'**
  String get settingsAddCredential;

  /// No description provided for @settingsNoCredentials.
  ///
  /// In es, this message translates to:
  /// **'Sin credenciales guardadas'**
  String get settingsNoCredentials;

  /// No description provided for @settingsEditCredential.
  ///
  /// In es, this message translates to:
  /// **'Editar credencial'**
  String get settingsEditCredential;

  /// No description provided for @settingsDeleteCredential.
  ///
  /// In es, this message translates to:
  /// **'Borrar credencial'**
  String get settingsDeleteCredential;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get settingsThemeDark;

  /// No description provided for @settingsLangEs.
  ///
  /// In es, this message translates to:
  /// **'Espanol'**
  String get settingsLangEs;

  /// No description provided for @settingsLangEn.
  ///
  /// In es, this message translates to:
  /// **'Ingles'**
  String get settingsLangEn;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonClose.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
