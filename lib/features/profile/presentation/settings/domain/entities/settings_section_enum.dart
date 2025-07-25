import 'package:zefyr/l10n/app_localizations.dart';

enum SettingsSection {
  main,
  tools,
  accounts;

  const SettingsSection();
}

extension SettingsSectionX on SettingsSection {
  String title(AppLocalizations local) => switch (this) {
    SettingsSection.main => 'Настройка',
    SettingsSection.tools => 'Инструменты',
    SettingsSection.accounts => 'Учетные записи',
  };
}
