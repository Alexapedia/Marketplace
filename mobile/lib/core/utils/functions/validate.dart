import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';

class Validate {
  static FilteringTextInputFormatter numberOnlyFormater =
      FilteringTextInputFormatter.allow(RegExp('[0-9]'));

  static LengthLimitingTextInputFormatter maxLengthFormater(int length) =>
      LengthLimitingTextInputFormatter(length);

  static RegExp upperCaseRegex = RegExp(r'[A-Z]');
  static RegExp lowerCaseRegex = RegExp(r'[a-z]');
  static RegExp phoneNumberRegex = RegExp(r'^\+?[0-9]{8,15}$');
  static RegExp digit = RegExp(r'\d');
  static RegExp specialChar = RegExp(r'[^A-Za-z0-9]');
  static RegExp emailRegex = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  static String? validateEmail(String email) {
    if (email.isEmpty) return 'email_error_empty'.tr();
    if (!emailRegex.hasMatch(email)) return 'email_not_valid'.tr();
    return null;
  }

  static String? validatePassword(String password) {
    if (password.isEmpty) return 'password_error_empty'.tr();
    if (password.length < 8) return 'password_8'.tr();
    if (!digit.hasMatch(password)) return 'least_one_number'.tr();
    if (!upperCaseRegex.hasMatch(password)) {
      return 'password_error_uppercase'.tr();
    }
    if (!lowerCaseRegex.hasMatch(password)) {
      return 'password_error_lowercase'.tr();
    }
    if (!specialChar.hasMatch(password)) return 'password_error_special'.tr();
    return null;
  }

  static String? notEmpty(String val) {
    if (val.trim().isEmpty) return 'can_not_be_empty'.tr();
    return null;
  }

  static String? validatePhoneNumber(String? number) {
    if (number == null || number.isEmpty) return 'number_required'.tr();
    if (!phoneNumberRegex.hasMatch(number)) return 'invalid_number'.tr();
    return null;
  }

  static String? confirmPassword(String password, String confirm) {
    if (confirm.isEmpty) return 'can_not_be_empty'.tr();
    if (password != confirm) return 'passwords_not_match'.tr();
    return null;
  }
}
