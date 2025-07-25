import 'package:flutter/material.dart';
import 'package:zefyr/features/profile/presentation/settings/domain/entities/settings_section_enum.dart';
import 'package:zefyr/l10n/app_localizations.dart';

enum SettingsOption {
  account(Icons.person, SettingsSection.main),
  notifications(
    Icons.notifications,
    SettingsSection.main,
    isToggle: true,
    defaultValue: true,
  ),
  darkTheme(
    Icons.brightness_2,
    SettingsSection.main,
    isToggle: true,
    defaultValue: true,
  ),
  language(Icons.language, SettingsSection.main, trailingText: 'Русский'),

  withdraw(Icons.account_balance_wallet, SettingsSection.tools),
  support(Icons.headset_mic, SettingsSection.tools),
  statistics(Icons.bar_chart, SettingsSection.tools),
  blocked(Icons.block, SettingsSection.tools),

  addAccount(Icons.person_add, SettingsSection.accounts),
  logout(Icons.logout, SettingsSection.accounts);

  const SettingsOption(
    this.icon,
    this.section, {
    this.isToggle = false,
    this.defaultValue = false,
    this.trailingText,
  });
  final IconData icon;
  final SettingsSection section;
  final bool isToggle;
  final bool defaultValue;
  final String? trailingText;
}

extension SettingsOptionLocalizationX on SettingsOption {
  String localizedTitle(AppLocalizations local) => switch (this) {
    SettingsOption.account => 'Данные об аккаунте',
    SettingsOption.notifications => 'Уведомления',
    SettingsOption.darkTheme => 'Темная тема',
    SettingsOption.language => 'Язык',
    SettingsOption.withdraw => 'Вывести деньги',
    SettingsOption.support => 'Служба поддержки',
    SettingsOption.statistics => 'Статистика',
    SettingsOption.blocked => 'Заблокированные',
    SettingsOption.addAccount => 'Добавить аккаунт',
    SettingsOption.logout => 'Выйти',
  };
  String? trailingText(AppLocalizations local, BuildContext context) =>
      switch (this) {
        SettingsOption.language => _languageDisplay(local),
        SettingsOption.darkTheme => null, // или currentThemeName
        _ => null,
      };

  String _languageDisplay(AppLocalizations local) {
    final locale = local.localeName;
    return switch (locale) {
      'ru' => 'Русский',
      'en' => 'English',
      _ => 'System',
    };
  }
}
