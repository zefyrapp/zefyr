// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get registerWithZefyr => 'Register with Zefyr';

  @override
  String get continueWithEmail => 'Continue with email address';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithEmail => 'Sign in with email';

  @override
  String get or => 'or';

  @override
  String get createAccount => 'Create account';

  @override
  String get termsConditionsText => 'By continuing to use an account related to the ';

  @override
  String get termsOfUse => 'Terms of Use ';

  @override
  String get toRegion => 'for the region ';

  @override
  String get regionKazakhstan => 'Kazakhstan';

  @override
  String get youAcceptAndConfirm => ', you accept and confirm that you have read the « ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get endQuote => '».';

  @override
  String termsAndPrivacyFullText(String termsOfUse, String region, String privacyPolicy) {
    return 'By continuing to use an account related to the $termsOfUse for the region $region, you accept and confirm that you have read the « $privacyPolicy».';
  }

  @override
  String get birthDateTitle => 'When is your birthday?';

  @override
  String get birthDateDescription => 'We won\'t show your birthday to other users.';

  @override
  String get birthDateLabel => 'Birthday';

  @override
  String get continueButton => 'Continue';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get emailPasswordPrompt => 'Enter your email address and create a password';

  @override
  String get enterEmail => 'Enter email address';

  @override
  String get enterValidEmail => 'Enter a valid email address';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get passwordLength => '8 characters (no more than 20)';

  @override
  String get passwordRequirements => '1 letter, 1 number, 1 special character (# ? ! @)';

  @override
  String get strongPassword => 'Strong password';

  @override
  String get emailUsernameLabel => 'Email address/username';

  @override
  String get emailUsername => 'Email or username';

  @override
  String get enterEmailUsername => 'Enter email or username';

  @override
  String get skip => 'Skip';

  @override
  String get createNickname => 'Create a nickname';

  @override
  String get nicknameDescription => 'Enter any nickname you like. If you skip this step, you will be automatically assigned a default nickname. You can change it later.';

  @override
  String get enterNickname => 'Enter nickname';
}
