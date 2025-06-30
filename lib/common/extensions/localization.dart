import 'package:flutter/widgets.dart';
import 'package:zefyr/l10n/app_localizations.dart';

extension ContextLocalization on BuildContext {
  AppLocalizations get localization => AppLocalizations.of(this)!;
}
