import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';
import '../constants/strings.dart';
import '../tabs/profile/profile_view.dart';
import '../dialogs/logout_dialog.dart';
import '../dialogs/alert_dialog_model.dart';
import '../../state/auth/providers/authentication_provider.dart';

PreferredSizeWidget buildMainAppBar(BuildContext context, WidgetRef ref) {
  return AppBar(
    toolbarHeight: 96,
    leadingWidth: 120,
    leading: TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ProfileView(),
          ),
        );
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(56, 56),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.account_circle,
            color: AppColors.buttonColor,
            size: 36,
          ),
          SizedBox(height: 4),
          Text(
            Strings.profile,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.hintColor, fontSize: 12),
          ),
        ],
      ),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: TextButton(
          onPressed: () async {
            final shouldLogOut =
                await const LogoutDialog().present(context).then((value) => value ?? false);

            if (shouldLogOut) {
              await ref.read(authenticationProvider.notifier).logOut();
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(56, 56),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.logout,
                color: AppColors.buttonColor,
                size: 36,
              ),
              SizedBox(height: 4),
              Text(
                Strings.logOut,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.hintColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget buildMainBottomNavigationBar(int currentIndex, void Function(int) onTap) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: currentIndex,
    onTap: onTap,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: Strings.home,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_to_photos),
        label: Strings.notes,
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.bar_chart),
        label: Strings.statistics,
      ),
    ],
  );
}
