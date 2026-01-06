import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headache_diary/views/tabs/statistics/statistics_picker_modal.dart';

import '../constants/app_colors.dart';
import '../constants/strings.dart';
import '../main/main_view.dart';
import '../dialogs/logout_dialog.dart';
import '../dialogs/alert_dialog_model.dart';
import '../../state/auth/providers/authentication_provider.dart';
import '../../state/user_info/user_info_provider.dart';
import '../tabs/calendar/day_action_modal.dart';
import '../tabs/calendar/day_view.dart';

PreferredSizeWidget buildMainAppBar(BuildContext context, WidgetRef ref) {
  return AppBar(
    toolbarHeight: 96,
    leadingWidth: 120,
    leading: TextButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MainView(initialIndex: 3),
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
        children: [
          const Icon(
            Icons.account_circle,
            color: AppColors.buttonColor,
            size: 36,
          ),
          const SizedBox(height: 4),
          Builder(builder: (context) {
            final authState = ref.watch(authenticationProvider);
            final userId = authState.userId;
            final userInfoAsync = ref.watch(userInfoModelProvider(userId!));

            return userInfoAsync.when(
              data: (userInfo) => Text(
                (userInfo.displayName.isNotEmpty) ? userInfo.displayName : Strings.profile,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.hintColor, fontSize: 12),
              ),
              loading: () => const Text(
                Strings.profile,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.hintColor, fontSize: 12),
              ),
              error: (_, _) => const Text(
                Strings.profile,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.hintColor, fontSize: 12),
              ),
            );
          }),
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

Widget buildMainBottomNavigationBar(BuildContext context, int currentIndex, void Function(int, [Map<String, dynamic>?]) onTap) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: currentIndex,
    onTap: (index) async {
      if (index == 1) {
        final date = (currentIndex == 0) ? DateTime.now() : DayView.activeDate.value;
        await Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (ctx, a1, a2) => DayActionModal(date: date),
          transitionsBuilder: (ctx, anim, sec, child) {
            final tween = Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
            return SlideTransition(position: anim.drive(tween), child: child);
          },
        ));
        return;
      }

      if (index == 2) {
        final result = await Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (ctx, a1, a2) => StatisticsPickerModal(),
          transitionsBuilder: (ctx, anim, sec, child) {
            final tween = Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: Curves.easeOut));
            return SlideTransition(position: anim.drive(tween), child: child);
          },
        ));

        // If user picked a mode, notify MainView via onTap and pass params
        if (result is Map<String, dynamic>) {
          onTap(2, result);
        }

        return;
      }

      onTap(index);
    },
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
