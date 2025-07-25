import 'package:flutter/material.dart';
import 'package:zefyr/common/widgets/scaffold_wrapper.dart';
import 'package:zefyr/l10n/l10n.dart';

class LanguageSettings extends StatefulWidget {
  const LanguageSettings({super.key});

  @override
  State<LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  Locale _selectedLocale = L10n.all.first;

  @override
  Widget build(BuildContext context) => ScaffoldWrapper(
    title: 'Язык',
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: L10n.all.map((locale) {
          final isSelected = locale == _selectedLocale;
          return ListTile(
            title: Text(
              locale.displayName,
              style: const TextStyle(
                fontSize: 18,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 24 / 18,
              ),
            ),
            trailing: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: isSelected
                  ? Container(
                      key: const ValueKey(true),
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.circle_outlined,
                      color: Colors.white38,
                      key: ValueKey(false),
                    ),
            ),
            onTap: () {
              setState(() {
                _selectedLocale = locale;
              });
            },
          );
        }).toList(),
      ),
    ),
  );
}
