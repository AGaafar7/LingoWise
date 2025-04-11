import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en', 'US'), // English
    Locale('ar', 'SA'), // Arabic
    Locale('de', 'DE'), // German
    Locale('fr', 'FR'), // French
    Locale('es', 'ES'), // Spanish
    Locale('pt', 'PT'), // Portuguese
    Locale('ru', 'RU'), // Russian
    Locale('zh', 'CN'), // Chinese
    Locale('ja', 'JP'), // Japanese
    Locale('ko', 'KR'), // Korean
    Locale('hi', 'IN'), // Hindi
    Locale('ms', 'MY'), // Malay
    Locale('tr', 'TR'), // Turkish
    Locale('id', 'ID'), // Indonesian
    Locale('bn', 'BD'), // Bengali
    Locale('vi', 'VN'), // Vietnamese
  ];
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return SynchronousFuture<AppLocalizations>(AppLocalizations());
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
