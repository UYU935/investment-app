import 'package:flutter/foundation.dart';
import '../l10n/app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  String _locale = 'ja';
  String get locale => _locale;
  AppStrings get strings => AppStrings(_locale);

  void setLocale(String locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}
