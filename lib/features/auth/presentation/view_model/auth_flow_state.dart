// Enum для отслеживания типа потока авторизации
enum AuthFlowType { login, register }

// Enum для отслеживания текущего шага
enum AuthStep {
  initial, // Выбор Login/Register
  emailInput, // Ввод email
  passwordInput, // Ввод пароля (для login)
  registerPassword, // Ввод пароля (для register)
  birthDate, // Выбор даты рождения
  nickname, // Ввод никнейма
}

// Модель данных для формы
class AuthFormData {
  const AuthFormData({
    this.email,
    this.password,
    this.birthDate,
    this.nickname,
  });
  final String? email;
  final String? password;
  final DateTime? birthDate;
  final String? nickname;

  AuthFormData copyWith({
    String? email,
    String? password,
    DateTime? birthDate,
    String? nickname,
  }) => AuthFormData(
    email: email ?? this.email,
    password: password ?? this.password,
    birthDate: birthDate ?? this.birthDate,
    nickname: nickname ?? this.nickname,
  );
}

// Состояние для AuthFlowViewModel
class AuthFlowState {
  const AuthFlowState({
    required this.currentStep,
    required this.formData,
    this.flowType,
    this.isLoading = false,
    this.errorMessage,
  });
  factory AuthFlowState.initial() => const AuthFlowState(
    currentStep: AuthStep.initial,
    formData: AuthFormData(),
  );
  final AuthFlowType? flowType;
  final AuthStep currentStep;
  final AuthFormData formData;
  final bool isLoading;
  final String? errorMessage;

  AuthFlowState copyWith({
    AuthFlowType? flowType,
    AuthStep? currentStep,
    AuthFormData? formData,
    bool? isLoading,
    bool? canResetError,
    String? errorMessage,
  }) => AuthFlowState(
    flowType: flowType ?? this.flowType,
    currentStep: currentStep ?? this.currentStep,
    formData: formData ?? this.formData,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: canResetError ?? false
        ? null
        : errorMessage ?? this.errorMessage,
  );
}
