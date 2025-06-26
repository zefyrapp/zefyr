// Страница выбора даты рождения
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zifyr/common/extensions/context_theme.dart';
import 'package:zifyr/common/extensions/localization.dart';
import 'package:zifyr/core/utils/icons/app_icons_icons.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_flow_view_model.dart';
import 'package:zifyr/features/auth/providers/auth_providers.dart';

class BirthDateView extends ConsumerStatefulWidget {
  const BirthDateView({super.key});
  @override
  ConsumerState<BirthDateView> createState() => _BirthDatePageState();
}

class _BirthDatePageState extends ConsumerState<BirthDateView> {
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;

  // Контроллеры для FixedExtentScrollController
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  @override
  void initState() {
    super.initState();
    _dayController = FixedExtentScrollController();
    _monthController = FixedExtentScrollController();
    _yearController = FixedExtentScrollController();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  DateTime? get _selectedDate {
    if (_selectedDay != null &&
        _selectedMonth != null &&
        _selectedYear != null) {
      return DateTime(_selectedYear!, _selectedMonth!, _selectedDay!);
    }
    return null;
  }

  List<String> _getMonthNames(BuildContext context) {
    final localizations = context.localization;
    return [
      localizations.january,
      localizations.february,
      localizations.march,
      localizations.april,
      localizations.may,
      localizations.june,
      localizations.july,
      localizations.august,
      localizations.september,
      localizations.october,
      localizations.november,
      localizations.december,
    ];
  }

  int _getDaysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    final authFlowViewModel = ref.read(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;
    final localizations = context.localization;
    final monthNames = _getMonthNames(context);

    return Scaffold(
      backgroundColor: color.backgroundColor,
      appBar: AppBar(
        backgroundColor: color.backgroundColor,
        surfaceTintColor: color.backgroundColor,
        leading: IconButton(
          icon: const Icon(AppIcons.left_shefron, size: 20),
          onPressed: authFlowViewModel.previousStep,
          color: color.white,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.birthDateTitle,
                style: TextStyle(
                  fontSize: 26,
                  height: 30 / 26,
                  fontWeight: FontWeight.w700,
                  color: color.white,
                ),
              ),

              const SizedBox(height: 16),
              Text(
                localizations.birthDateDescription,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  height: 1,
                  color: Color(0xff9CA3AF),
                ),
              ),

              const SizedBox(height: 16),

              // Контейнер с заголовком "День рождения"
              Container(
                width: double.infinity,
                height: 56,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff1F2937),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ref.watch(authFlowViewModelProvider).formData.birthDate !=
                          null
                      ? DateFormat(
                          'dd MMMM yyyy',
                          localizations.localeName,
                        ).format(
                          ref
                              .watch(authFlowViewModelProvider)
                              .formData
                              .birthDate!,
                        )
                      : localizations.birthDateLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    height: 24 / 16,
                    color: Color(0xffADAEBC),
                  ),
                ),
              ),
              const SizedBox(height: 56),
              // Picker для выбора даты
              Center(
                child: SizedBox(
                  height: 340,
                  child: Row(
                    children: [
                      // День
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _dayController,
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedDay = index + 1;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount:
                                _selectedMonth != null && _selectedYear != null
                                ? _getDaysInMonth(
                                    _selectedYear!,
                                    _selectedMonth!,
                                  )
                                : 31,
                            builder: (context, index) {
                              final day = index + 1;
                              final isSelected = _selectedDay == day;
                              return Center(
                                child: Text(
                                  day.toString(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 20 : 18,
                                    height: 1,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? color.white
                                        : const Color(0xff6B7280),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Месяц
                      Expanded(
                        flex: 2,
                        child: ListWheelScrollView.useDelegate(
                          controller: _monthController,
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedMonth = index + 1;
                              // Проверяем, не превышает ли выбранный день количество дней в новом месяце
                              if (_selectedDay != null &&
                                  _selectedYear != null) {
                                final daysInMonth = _getDaysInMonth(
                                  _selectedYear!,
                                  _selectedMonth!,
                                );
                                if (_selectedDay! > daysInMonth) {
                                  _selectedDay = daysInMonth;
                                  _dayController.animateToItem(
                                    _selectedDay! - 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 12,
                            builder: (context, index) {
                              final monthName = monthNames[index];
                              final isSelected = _selectedMonth == index + 1;
                              return Center(
                                child: Text(
                                  monthName,
                                  style: TextStyle(
                                    fontSize: isSelected ? 20 : 18,
                                    height: 1,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? color.white
                                        : const Color(0xff6B7280),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Год
                      Expanded(
                        child: ListWheelScrollView.useDelegate(
                          controller: _yearController,
                          itemExtent: 40,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedYear = DateTime.now().year - index;
                              // Проверяем февраль в високосном году
                              if (_selectedDay != null &&
                                  _selectedMonth != null) {
                                final daysInMonth = _getDaysInMonth(
                                  _selectedYear!,
                                  _selectedMonth!,
                                );
                                if (_selectedDay! > daysInMonth) {
                                  _selectedDay = daysInMonth;
                                  _dayController.animateToItem(
                                    _selectedDay! - 1,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              }
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: DateTime.now().year - 1900 + 1,
                            builder: (context, index) {
                              final year = DateTime.now().year - index;
                              final isSelected = _selectedYear == year;
                              return Center(
                                child: Text(
                                  year.toString(),
                                  style: TextStyle(
                                    fontSize: isSelected ? 20 : 18,
                                    height: 1,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? color.white
                                        : const Color(0xff6B7280),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: color.elevatedStyle,
                  onPressed: _selectedDate == null
                      ? null
                      : () {
                          authFlowViewModel.updateFormData(
                            ref
                                .read(authFlowViewModelProvider)
                                .formData
                                .copyWith(birthDate: _selectedDate),
                          );
                          authFlowViewModel.nextStep();
                        },
                  child: Text(
                    localizations.continueButton,
                    style: color.elevatedTextStyle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
