// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_flow_state.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_state.dart';
import 'package:zefyr/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:zefyr/features/auth/providers/auth_providers.dart';

part 'auth_flow_view_model.g.dart';

@riverpod
class AuthFlowViewModel extends _$AuthFlowViewModel {
  @override
  AuthFlowState build() {
    ref.onDispose(() => _pageController.dispose());
    return AuthFlowState.initial();
  }

  AuthViewModel get _authViewModel => ref.read(authViewModelProvider.notifier);

  final PageController _pageController = PageController();

  PageController get pageController => _pageController;

  // Устанавливаем тип потока (login/register) и переходим к вводу email
  void setFlowType(AuthFlowType type) {
    state = state.copyWith(flowType: type, errorMessage: null);
    _navigateToStep(
      type == AuthFlowType.login ? AuthStep.emailLogin : AuthStep.emailInput,
    );
  }

  // Обновляем данные формы
  void updateFormData(AuthFormData data) {
    state = state.copyWith(formData: data, errorMessage: null);
  }

  // Переход к следующему шагу
  void nextStep() => switch (state.currentStep) {
    AuthStep.initial => null,
    AuthStep.emailInput => _navigateToStep(AuthStep.birthDate),
    AuthStep.emailLogin => _navigateToStep(AuthStep.passwordInput),
    AuthStep.passwordInput => _performLogin(),
    AuthStep.birthDate => _navigateToStep(AuthStep.nickname),
    AuthStep.nickname => _performRegister(),
  };

  // Переход к предыдущему шагу
  void previousStep() => switch (state.currentStep) {
    AuthStep.emailInput => _navigateToStep(AuthStep.initial),

    AuthStep.emailLogin => _navigateToStep(AuthStep.initial),
    AuthStep.passwordInput => _navigateToStep(AuthStep.emailLogin),
    AuthStep.birthDate => _navigateToStep(AuthStep.emailInput),
    AuthStep.nickname => _navigateToStep(AuthStep.birthDate),
    AuthStep.initial => null,
  };

  // Пропуск шага никнейма
  void skipNickname() {
    if (state.currentStep == AuthStep.nickname) {
      _performRegister();
    }
  }

  // Навигация к определенному шагу
  void _navigateToStep(AuthStep step) {
    state = state.copyWith(currentStep: step, errorMessage: null);
    final pageIndex = _getPageIndex(step);
    // Используем WidgetsBinding для отложенной навигации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        // _pageController.animateToPage(
        //   pageIndex,
        //   duration: const Duration(milliseconds: 100),
        //   curve: Curves.easeInOut,
        // );
        _pageController.jumpToPage(pageIndex);
      }
    });
  }

  // Получение индекса страницы для PageView
  int _getPageIndex(AuthStep step) => switch (step) {
    AuthStep.initial => 0,
    AuthStep.emailInput => 1,
    AuthStep.birthDate => 2,
    AuthStep.nickname => 3,
    AuthStep.emailLogin => 4,
    AuthStep.passwordInput => 5,
  };

  // Выполнение авторизации
  Future<void> _performLogin() async {
    if (state.formData.email == null || state.formData.password == null) {
      state = state.copyWith(errorMessage: 'Заполните все поля');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authViewModel.login(
        state.formData.email!,
        state.formData.password!,
      );

      // Проверяем результат авторизации
      final authState = _authViewModel.state;
      if (authState is AuthError) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: authState.message,
        );
      } else if (authState is AuthAuthenticated) {
        state = state.copyWith(isLoading: false);
        // Успешная авторизация - навигация обрабатывается в основном приложении
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Произошла ошибка при авторизации',
      );
    }
  }

  // Выполнение регистрации
  Future<void> _performRegister() async {
    if (state.formData.email == null || state.formData.password == null) {
      state = state.copyWith(errorMessage: 'Заполните обязательные поля');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Используем nickname или email как имя, если nickname не указан
      final name = state.formData.nickname?.isNotEmpty ?? false
          ? state.formData.nickname!
          : state.formData.email!.split('@').first;

      await _authViewModel.register(
        state.formData.email!,
        state.formData.password!,
        DateFormat('yyyy-MM-dd').format(state.formData.birthDate!),

        name,
      );

      // Проверяем результат регистрации
      final authState = _authViewModel.state;
      if (authState is AuthError) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: authState.message,
        );
      } else if (authState is AuthAuthenticated) {
        state = state.copyWith(isLoading: false);
        // Успешная регистрация - навигация обрабатывается в основном приложении
        
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Произошла ошибка при регистрации',
      );
    }
  }

  // Сброс состояния к начальному
  void reset() {
    state = AuthFlowState.initial();
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
