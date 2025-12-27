import '../../constants/strings.dart';

String? validateName(String? name) {
  if (name == null || name.isEmpty) {
    return Strings.enterYourName;
  }
  return null;
}

String? validateEmail(String? email) {
  if (email == null || email.isEmpty) {
    return Strings.enterYourEmailAddress;
  }
  final emailRegex = RegExp(r'^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
  if (!emailRegex.hasMatch(email)) {
    return Strings.enterCorrectEmailAddress;
  }

  return null;
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return Strings.enterYourPassword;
  }
  if (password.length < 5) {
    return Strings.shortPassword;
  }
  if (!RegExp(r'[A-Z]').hasMatch(password)) {
    return Strings.passwordMustContainUppercase;
  }
  return null;
}