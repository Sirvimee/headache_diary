import '../constants/strings.dart';
import 'alert_dialog_model.dart';
import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

class LogoutDialog extends AlertDialogModel<bool> {
  const LogoutDialog()
      : super(
    title: Strings.logOut,
    message: Strings.areYouSureYouWantToLogOut,
    buttons: const {
      Strings.cancel: false,
      Strings.logOut: true,
    },
    buttonTextStyles: const {
      Strings.cancel: TextStyle(color: AppColors.grey),
      Strings.logOut: TextStyle(color: AppColors.buttonColor),
    },
  );
}