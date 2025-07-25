import 'package:flutter/material.dart';

class L10n {
  static final all = [const Locale('ru'), const Locale('en')];
}

extension LocaleNameExtension on Locale {
  String get displayName => switch (languageCode) {
    'ru' => 'Русский',
    'en' => 'English',
    _ => languageCode,
  };
}
