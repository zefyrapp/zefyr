import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zifyr/common/extensions/context_theme.dart';
import 'package:zifyr/common/extensions/localization.dart';
import 'package:zifyr/common/themes/app_overlay.dart';
import 'package:zifyr/core/utils/icons/app_icons_icons.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_flow_state.dart';
import 'package:zifyr/features/auth/presentation/view_model/auth_flow_view_model.dart';
import 'package:zifyr/features/auth/usecases/enums/auth_sign_enum.dart';
import 'package:zifyr/features/auth/usecases/privacy_text.dart';

class AuthFlowView extends ConsumerWidget {
  const AuthFlowView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authFlowViewModel = ref.watch(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;
    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: PageView(
          controller: authFlowViewModel.pageController,
          physics: const NeverScrollableScrollPhysics(), // Отключаем свайп
          children: const [
            // Страница 0: Выбор типа авторизации
            AuthView(),

            // Страница 1: Ввод email
            _EmailInputPage(),

            // Страница 2: Ввод пароля
            _PasswordInputPage(),

            // Страница 3: Выбор даты рождения (только для регистрации)
            _BirthDatePage(),

            // Страница 4: Ввод никнейма (только для регистрации)
            _NicknamePage(),
          ],
        ),
      ),
    );
  }
}

class AuthView extends StatelessWidget {
  /// Страница авторизации
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    final local = context.localization;
    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 194),
              Text(
                local.registerWithZefyr,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  height: 38 / 30,
                  color: color.white,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Consumer(
                  builder: (context, ref, _) => Column(
                    children: AuthSignEnum.values
                        .mapIndexed(
                          (i, el) => Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                            color: const Color(0xff374151),
                            clipBehavior: Clip.hardEdge,
                            child: ListTile(
                              onTap: () => el.onTap(
                                ref.read(authFlowViewModelProvider.notifier),
                              ),
                              leading: i == 1
                                  ? SvgPicture.asset(
                                      el.icon as String,
                                      color: color.white,
                                      width: 16,
                                      height: 16,
                                    )
                                  : Icon(
                                      el.icon as IconData,
                                      color: color.white,
                                      size: 16,
                                    ),
                              title: Text(
                                el.title(context),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  height: 1,
                                  color: color.white,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              const Spacer(),
              PrivacyText.buildStyledTermsText(context),

              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) => Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: local.alreadyHaveAccount,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 24 / 16,
                          color: Color(0xffc5c5c5),
                        ),
                      ),
                      TextSpan(
                        text: local.signIn,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => ref
                              .read(authFlowViewModelProvider.notifier)
                              .setFlowType(AuthFlowType.login),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          height: 24 / 16,
                          color: Colors.red,
                        ),
                      ),
                    ],
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

class _EmailInputPage extends ConsumerStatefulWidget {
  const _EmailInputPage({super.key});
  @override
  ConsumerState<_EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends ConsumerState<_EmailInputPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authFlowState = ref.watch(authFlowViewModelProvider);
    final authFlowViewModel = ref.read(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;

    return Scaffold(
      backgroundColor: color.backgroundColor,
      appBar: AppBar(
        backgroundColor: color.backgroundColor,
        leading: IconButton(
          icon: const Icon(AppIcons.left_shefron, size: 20),
          onPressed: authFlowViewModel.previousStep,
          color: color.white,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authFlowState.flowType == AuthFlowType.login
                      ? 'Вход в аккаунт'
                      : 'Введите адрес эл. почты и придумайте пароль',
                  style: TextStyle(
                    fontSize: 22,
                    height: 32 / 22,
                    fontWeight: FontWeight.w700,
                    color: color.white,
                  ),
                ),

                const SizedBox(height: 32),

                AppTextField.email(
                  hintText: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите email';
                    }
                    if (!value.contains('@')) {
                      return 'Введите корректный email';
                    }
                    return null;
                  },
                  onChanged: (value) {},
                ),
                const SizedBox(height: 22),
                AppTextField.password(
                  hintText: 'Введите пароль',

                  onChanged: (value) {},
                ),

                if (authFlowState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    authFlowState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authFlowState.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              authFlowViewModel.updateFormData(
                                authFlowState.formData.copyWith(
                                  email: _emailController.text.trim(),
                                ),
                              );
                              authFlowViewModel.nextStep();
                            }
                          },
                    child: authFlowState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Продолжить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.hintText,
    super.key,
    this.keyboardType,
    this.validator,
    this.onChanged,
  }) : isPassword = false;

  const AppTextField.email({
    required this.hintText,
    super.key,
    this.validator,
    this.onChanged,
  }) : keyboardType = TextInputType.emailAddress,
       isPassword = false;
  const AppTextField.password({
    required this.hintText,
    super.key,
    this.validator,
    this.onChanged,
  }) : keyboardType = TextInputType.visiblePassword,
       isPassword = true;
  final TextInputType? keyboardType;
  final String hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late bool _obscureText;
  @override
  void initState() {
    _controller = TextEditingController();
    _obscureText = widget.isPassword;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleObscureText() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.customTheme.overlayApp;
    return Container(
      height: 58,
      decoration: BoxDecoration(color: color.textFieldBackgroundColor),
      child: TextFormField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        style: TextStyle(color: color.white),
        obscureText: _obscureText,
        cursorHeight: 16,
        cursorWidth: 4,
        decoration: InputDecoration(
          hint: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(widget.hintText, style: color.hintTextStyle),
          ),
          border: color.textFieldBorder,
          focusedBorder: color.textFieldBorder,
          suffix: widget.isPassword
              ? InkWell(
                  onTap: _toggleObscureText,
                  child: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: color.white,
                  ),
                )
              : null,
        ),
        onChanged: widget.onChanged,
        validator: widget.validator,
      ),
    );
  }
}

// Страница ввода пароля
class _PasswordInputPage extends ConsumerStatefulWidget {
  const _PasswordInputPage({super.key});
  @override
  ConsumerState<_PasswordInputPage> createState() => _PasswordInputPageState();
}

class _PasswordInputPageState extends ConsumerState<_PasswordInputPage> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authFlowState = ref.watch(authFlowViewModelProvider);
    final authFlowViewModel = ref.read(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;
    final isLogin = authFlowState.flowType == AuthFlowType.login;

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: authFlowViewModel.previousStep,
                  icon: Icon(Icons.arrow_back, color: color.white),
                ),

                const SizedBox(height: 24),

                Text(
                  isLogin ? 'Введите пароль' : 'Создайте пароль',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color.white,
                  ),
                ),

                const SizedBox(height: 8),
                Text(
                  'Email: ${authFlowState.formData.email}',
                  style: TextStyle(color: color.white.withOpacity(0.7)),
                ),

                const SizedBox(height: 32),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: color.white),
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    labelStyle: TextStyle(color: color.white.withOpacity(0.7)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: color.white.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: color.white.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: color.white),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: color.white.withOpacity(0.7),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите пароль';
                    }
                    if (!isLogin && value.length < 6) {
                      return 'Пароль должен содержать минимум 6 символов';
                    }
                    return null;
                  },
                ),

                if (authFlowState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    authFlowState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authFlowState.isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              authFlowViewModel.updateFormData(
                                authFlowState.formData.copyWith(
                                  password: _passwordController.text,
                                ),
                              );
                              authFlowViewModel.nextStep();
                            }
                          },
                    child: authFlowState.isLoading
                        ? const CircularProgressIndicator()
                        : Text(isLogin ? 'Войти' : 'Продолжить'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Страница выбора даты рождения
class _BirthDatePage extends ConsumerStatefulWidget {
  const _BirthDatePage({super.key});
  @override
  ConsumerState<_BirthDatePage> createState() => _BirthDatePageState();
}

class _BirthDatePageState extends ConsumerState<_BirthDatePage> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final authFlowViewModel = ref.read(authFlowViewModelProvider.notifier);
    final color = context.customTheme.overlayApp;

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: authFlowViewModel.previousStep,
                icon: Icon(Icons.arrow_back, color: color.white),
              ),

              const SizedBox(height: 24),

              Text(
                'Дата рождения',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color.white,
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Выберите вашу дату рождения',
                style: TextStyle(color: color.white.withOpacity(0.7)),
              ),

              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: color.white.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      ),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate == null
                            ? 'Выберите дату'
                            : '${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate == null
                              ? color.white.withOpacity(0.7)
                              : color.white,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today,
                        color: color.white.withOpacity(0.7),
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
                  child: const Text('Продолжить'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NicknamePage extends StatelessWidget {
  const _NicknamePage({super.key});

  @override
  Widget build(BuildContext context) => Container();
}
