import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zefyr/common/extensions/localization.dart';
import 'package:zefyr/common/widgets/scaffold_wrapper.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';
import 'package:zefyr/features/profile/presentation/settings/domain/entities/settings_option_enum.dart';
import 'package:zefyr/features/profile/presentation/settings/domain/entities/settings_section_enum.dart';

class ProfileSettings extends ConsumerStatefulWidget {
  const ProfileSettings({super.key});

  @override
  ConsumerState<ProfileSettings> createState() => _ProfileSettingsState();
}

class _ProfileSettingsState extends ConsumerState<ProfileSettings> {
  final Map<SettingsOption, bool> toggleValues = {};

  @override
  void initState() {
    super.initState();
    for (final option in SettingsOption.values.where((e) => e.isToggle)) {
      toggleValues[option] = option.defaultValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <SettingsSection, List<SettingsOption>>{};
    for (final item in SettingsOption.values) {
      grouped.putIfAbsent(item.section, () => []).add(item);
    }

    return ScaffoldWrapper(
      title: 'Настройка',
      body: ListView(
        children: grouped.entries
            .expand(
              (entry) => [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Text(
                    entry.key.title(context.localization),
                    style: const TextStyle(
                      color: Color(0xff6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',

                      height: 20 / 14,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
                ...entry.value.map(_buildTile),
              ],
            )
            .toList(),
      ),
    );
  }

  Widget _buildTile(SettingsOption option) {
    Widget? trailing;

    if (option.isToggle) {
      trailing = SizedBox(
        width: 44,
        height: 24,
        child: SwitchTheme(
          data: SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return Colors.grey.shade200;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xff22C55E);
              }
              return Colors.grey.shade400;
            }),
          ),
          child: Transform.scale(
            scale: 0.7,
            child: Switch.adaptive(
              value: toggleValues[option] ?? false,
              onChanged: (val) => setState(() {
                toggleValues[option] = val;
              }),
            ),
          ),
        ),
      );
    } else if (option.trailingText != null) {
      trailing = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            option.trailingText!,
            style: const TextStyle(
              color: Color(0xff7B7B7B),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
              height: 24 / 16,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      );
    }

    return ListTile(
      onTap: option.isToggle
          ? null
          : () {
              if (option.name == 'logout') {
                ref.read(userDaoProvider).clearUser();
              } else {
                context.push('/profile/settings/${option.name}');
              }
            },
      leading: Icon(option.icon, color: Colors.white),
      title: Text(
        option.localizedTitle(context.localization),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.w500,
          height: 24 / 16,
        ),
      ),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
