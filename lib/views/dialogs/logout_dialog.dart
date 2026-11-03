import '../constants/strings.dart';
import 'alert_dialog_model.dart';
import '../constants/app_colors.dart';
import 'package:flutter/material.dart';

class LogoutDialog extends AlertDialogModel<bool> {
  LogoutDialog()
      : super(
    title: Strings.logOut,
    message: Strings.areYouSureYouWantToLogOut,
    buttons: {
      Strings.cancel: false,
      Strings.logOut: true,
    },
    buttonTextStyles: {
      Strings.cancel: TextStyle(color: AppColors.grey),
      Strings.logOut: TextStyle(color: AppColors.buttonColor),
    },
  );
}