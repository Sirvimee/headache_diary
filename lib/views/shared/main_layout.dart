import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:headache_diary/views/tabs/statistics/statistics_picker_modal.dart';

import '../constants/app_colors.dart';
import '../constants/strings.dart';
import '../main/main_view.dart';
import '../dialogs/logout_dialog.dart';
import '../dialogs/alert_dialog_model.dart';
import '../../state/auth/providers/authentication_provider.dart';
import '../../state/auth/models/auth_result.dart';
import '../../state/user_info/user_info_provider.dart';
import '../tabs/calendar/day_action_modal.dart';
import '../tabs/calendar/day_view.dart';

PreferredSizeWidget buildMainAppBar(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback onVoiceEntry,
}) {
  final isGuest = ref.watch(authenticationProvider).result == AuthResult.local;

  return AppBar(
    toolbarHeight: 96,
    centerTitle: true,
    leadingWidth: 120,
    leading: TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MainView(initialIndex: 3),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size(56, 56),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle,
                  color: AppColors.buttonColor,
                  size: 36,
                ),
                SizedBox(height: 4),
                Builder(
                  builder: (context) {
                    final authState = ref.watch(authenticationProvider);
                    final userId = authState.userId;

                    if (isGuest) {
                      return Text(
                        Strings.profile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.hintColor,
                          fontSize: 12,
                        ),
                      );
                    }

                    // If there's no userId (user not logged in / logging out), don't try to
                    // watch the userInfo provider with a null id. Show the profile label as fallback.
                    if (userId == null) {
                      final firebaseName =
                          FirebaseAuth.instance.currentUser?.displayName;
                      return Text(
                        firebaseName?.isNotEmpty == true
                            ? firebaseName!
                            : Strings.profile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.hintColor,
                          fontSize: 12,
                        ),
                      );
                    }

                    final firebaseName =
                        FirebaseAuth.instance.currentUser?.displayName;
                    final userInfoAsync = ref.watch(
                      userInfoModelProvider(userId),
                    );

                    return userInfoAsync.when(
                      data: (userInfo) => Text(
                        (userInfo.displayName.isNotEmpty)
                            ? userInfo.displayName
                            : (firebaseName?.isNotEmpty == true
                                  ? firebaseName!
                                  : Strings.profile),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.hintColor,
                          fontSize: 12,
                        ),
                      ),
                      loading: () => Text(
                        firebaseName?.isNotEmpty == true
                            ? firebaseName!
                            : Strings.profile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.hintColor,
                          fontSize: 12,
                        ),
                      ),
                      error: (_, __) => Text(
                        firebaseName?.isNotEmpty == true
                            ? firebaseName!
                            : Strings.profile,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.hintColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    title: IconButton(
      tooltip: Strings.voiceEntry,
      icon: Icon(Icons.mic_none, color: AppColors.buttonColor, size: 36),
      onPressed: onVoiceEntry,
    ),
    actions: [
      Padding(
        padding: EdgeInsets.only(right: 20.0),
        child: TextButton(
          onPressed: () async {
            final shouldLogOut = await LogoutDialog()
                .present(context)
                .then((value) => value ?? false);

            if (shouldLogOut) {
              await ref.read(authenticationProvider.notifier).logOut();
              // Ensure navigation returns to root so AuthView (which shows LoginView when
              // logged out) is visible. Pop all routes until the first.
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(56, 56),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: AppColors.buttonColor, size: 36),
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

Widget buildMainBottomNavigationBar(
  BuildContext context,
  int currentIndex,
  void Function(int, [Map<String, dynamic>?]) onTap,
) {
  return BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    currentIndex: currentIndex,
    onTap: (index) async {
      if (index == 1) {
        final date = (currentIndex == 0)
            ? DateTime.now()
            : DayView.activeDate.value;
        await Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (ctx, a1, a2) => DayActionModal(date: date),
            transitionsBuilder: (ctx, anim, sec, child) {
              final tween = Tween(
                begin: Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut));
              return SlideTransition(position: anim.drive(tween), child: child);
            },
          ),
        );
        return;
      }

      if (index == 2) {
        final result = await Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            pageBuilder: (ctx, a1, a2) => StatisticsPickerModal(),
            transitionsBuilder: (ctx, anim, sec, child) {
              final tween = Tween(
                begin: Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut));
              return SlideTransition(position: anim.drive(tween), child: child);
            },
          ),
        );

        // If user picked a mode, notify MainView via onTap and pass params
        if (result is Map<String, dynamic>) {
          onTap(2, result);
        }

        return;
      }

      onTap(index);
    },
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: Strings.home),
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
