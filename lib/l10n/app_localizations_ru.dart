// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get home => 'Главная';

  @override
  String get registerWithZefyr => 'Зарегистрироваться в Zefyr';

  @override
  String get continueWithEmail => 'Продолжить с адресом эл. почты';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get resetPassword => 'Сбросить пароль';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Подтвердить пароль';

  @override
  String get signInWithGoogle => 'Войти с помощью Google';

  @override
  String get signInWithApple => 'Войти с помощью Apple';

  @override
  String get signInWithEmail => 'Войти с помощью эл. почты';

  @override
  String get or => 'или';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get termsConditionsText => 'Продолжая пользоваться аккаунтом, относящимся ';

  @override
  String get termsOfUse => 'Условия использования ';

  @override
  String get toRegion => 'к региону ';

  @override
  String get regionKazakhstan => 'Казахстан';

  @override
  String get youAcceptAndConfirm => ', вы принимаете и подтверждаете, что ознакомились с документом « ';

  @override
  String get privacyPolicy => 'Политику конфиденциальности';

  @override
  String get endQuote => '».';

  @override
  String termsAndPrivacyFullText(String termsOfUse, String region, String privacyPolicy) {
    return 'Продолжая пользоваться аккаунтом, относящимся $termsOfUse к региону $region, вы принимаете и подтверждаете, что ознакомились с документом « $privacyPolicy».';
  }

  @override
  String get birthDateTitle => 'Когда у вас день рождения?';

  @override
  String get birthDateDescription => 'Мы не покажем ваш день рождения другим пользователям.';

  @override
  String get birthDateLabel => 'День рождения';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get january => 'Января';

  @override
  String get february => 'Февраля';

  @override
  String get march => 'Марта';

  @override
  String get april => 'Апреля';

  @override
  String get may => 'Мая';

  @override
  String get june => 'Июня';

  @override
  String get july => 'Июля';

  @override
  String get august => 'Августа';

  @override
  String get september => 'Сентебря';

  @override
  String get october => 'Октебря';

  @override
  String get november => 'Ноября';

  @override
  String get december => 'Декабря';

  @override
  String get emailPasswordPrompt => 'Введите адрес эл. почты и придумайте пароль';

  @override
  String get enterEmail => 'Введите электронную почту';

  @override
  String get enterValidEmail => 'Введите корректую электронную почту';

  @override
  String get enterPassword => 'Введите пароль';

  @override
  String get passwordLength => '8 символов (не более 20)';

  @override
  String get passwordRequirements => '1 буква, 1 цифра, 1 специальный символ (# ? ! @)';

  @override
  String get strongPassword => 'Надежный пароль';

  @override
  String get emailUsernameLabel => 'Адрес эл. почты/имя пользователя';

  @override
  String get emailUsername => 'Почта или имя пользователя';

  @override
  String get enterEmailUsername => 'Введите почту или имя пользователя';

  @override
  String get skip => 'Пропустить';

  @override
  String get createNickname => 'Создайте никнейм';

  @override
  String get nicknameDescription => 'Укажите любой никнейм, который вам нравится. Если пропустить этот шаг, вам будет автоматически присвоен стандартный никнейм. Его можно будет изменить позже.';

  @override
  String get enterNickname => 'Введите никнейм';

  @override
  String get passwordLengthError => 'Пароль должен быть от 8 до 20 символов';

  @override
  String get passwordShouldContainAll => 'Пароль должен содержать хотя бы одну букву, цифру и специальный символ';
}
