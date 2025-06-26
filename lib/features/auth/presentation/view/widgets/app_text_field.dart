import 'package:flutter/material.dart';
import 'package:zifyr/common/extensions/context_theme.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    required this.hintText,
    super.key,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.controller,
  }) : isPassword = false,
       isNickname = false;
  const AppTextField.email({
    required this.hintText,
    super.key,
    this.validator,
    this.onChanged,
    this.controller,
  }) : keyboardType = TextInputType.emailAddress,
       isPassword = false,
       isNickname = false;
  const AppTextField.password({
    required this.hintText,
    super.key,
    this.validator,
    this.onChanged,
    this.controller,
  }) : keyboardType = TextInputType.visiblePassword,
       isPassword = true,
       isNickname = false;
  const AppTextField.nickname({
    required this.hintText,
    super.key,
    this.validator,
    this.onChanged,
    this.controller,
  }) : keyboardType = TextInputType.text,
       isPassword = false,
       isNickname = true;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  final bool isNickname;
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late bool _obscureText;
  static const int _nicknameMaxLength = 30;
  @override
  void initState() {
    _controller = widget.controller ?? TextEditingController();
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: color.textFieldBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _controller,
            keyboardType: widget.keyboardType,
            style: TextStyle(color: color.white),
            obscureText: _obscureText,
            cursorHeight: 16,
            cursorWidth: 4,
            maxLength: widget.isNickname ? _nicknameMaxLength : null,
            decoration: InputDecoration(
              counterText: '',
              hint: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(widget.hintText, style: color.hintTextStyle),
              ),
              border: color.textFieldBorder,
              focusedBorder: color.textFieldBorder,
              errorBorder: color.textFieldBorder,
              focusedErrorBorder: color.textFieldBorder,
              errorStyle: const TextStyle(
                height: 0,
                fontSize: 0,
              ), // Скрываем встроенный текст ошибки
              suffixIcon: widget.isPassword
                  ? InkWell(
                      onTap: _toggleObscureText,
                      child: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                        color: color.white,
                      ),
                    )
                  : widget.isNickname
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 19,
                        horizontal: 16,
                      ),
                      child: Text(
                        '${_controller.text.length}/$_nicknameMaxLength',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          height: 20 / 14,
                          color: Color(0xff6B7280),
                        ),
                      ),
                    )
                  : null,
            ),
            onChanged: (value) {
              if (widget.isNickname) {
                setState(() {});
              }
              widget.onChanged?.call(value);
            },
            validator: widget.validator,
          ),
        ),
        Builder(
          builder: (context) {
            final formFieldState = context
                .findAncestorStateOfType<FormFieldState<String>>();
            final errorText = formFieldState?.errorText;

            if (errorText != null && errorText.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                child: Text(
                  errorText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    height: 24 / 14,
                    color: Color(0xffFF4949),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
