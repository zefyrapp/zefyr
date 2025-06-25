import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zifyr/common/extensions/localization.dart';

abstract class PrivacyText {
  static Widget buildStyledTermsText(BuildContext context) {
    final local = context.localization;

    // Получаем полный текст с подстановками
    final fullText = local.termsAndPrivacyFullText(
      local.termsOfUse,
      local.regionKazakhstan,
      local.privacyPolicy,
    );

    // Находим позиции ключевых фраз для стилизации
    final termsOfUseText = local.termsOfUse;
    final regionText = local.regionKazakhstan;
    final privacyPolicyText = local.privacyPolicy;

    final termsIndex = fullText.indexOf(termsOfUseText);
    final regionIndex = fullText.indexOf(regionText);
    final privacyIndex = fullText.indexOf(privacyPolicyText);

    final List<TextSpan> spans = [];
    int currentIndex = 0;

    // Добавляем текст до "Условия использования"
    if (termsIndex > currentIndex) {
      spans.add(
        TextSpan(
          text: fullText.substring(currentIndex, termsIndex),
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 14 / 12,
            color: Color(0xffc5c5c5),
          ),
        ),
      );
      currentIndex = termsIndex;
    }

    // Добавляем "Условия использования" со стилем
    spans.add(
      TextSpan(
        text: termsOfUseText,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 14 / 12,
          color: Color(0xffffffff),
          decoration: TextDecoration.underline,
        ),
      ),
    );
    currentIndex += termsOfUseText.length;

    // Добавляем текст до региона
    if (regionIndex > currentIndex) {
      spans.add(
        TextSpan(
          text: fullText.substring(currentIndex, regionIndex),
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 14 / 12,
            color: Color(0xffc5c5c5),
          ),
        ),
      );
      currentIndex = regionIndex;
    }

    // Добавляем регион со стилем
    spans.add(
      TextSpan(
        text: regionText,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 14 / 12,
          color: Color(0xffffffff),
        ),
      ),
    );
    currentIndex += regionText.length;

    // Добавляем текст до "Политика конфиденциальности"
    if (privacyIndex > currentIndex) {
      spans.add(
        TextSpan(
          text: fullText.substring(currentIndex, privacyIndex),
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 14 / 12,
            color: Color(0xffc5c5c5),
          ),
        ),
      );
      currentIndex = privacyIndex;
    }

    // Добавляем "Политика конфиденциальности" со стилем и тапом
    spans.add(
      TextSpan(
        text: privacyPolicyText,
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // Обработка нажатия на политику конфиденциальности
          },
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          height: 14 / 12,
          color: Color(0xffffffff),
          decoration: TextDecoration.underline,
        ),
      ),
    );
    currentIndex += privacyPolicyText.length;

    // Добавляем оставшийся текст
    if (currentIndex < fullText.length) {
      spans.add(
        TextSpan(
          text: fullText.substring(currentIndex),
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
            height: 14 / 12,
            color: Color(0xffc5c5c5),
          ),
        ),
      );
    }

    return Text.rich(TextSpan(children: spans), textAlign: TextAlign.center);
  }
}
