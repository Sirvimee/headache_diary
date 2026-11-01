import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headache_diary/router/router.dart';
import 'firebase_options.dart';
import 'views/constants/app_colors.dart';
import 'services/notifications/notification_service.dart';
import 'state/auth/backend/local_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.initialize();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryColor,
    ).copyWith(surface: AppColors.primaryColor);

    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.primaryColor,
        // Make all regular/display text white by default so TextField input inherits white color
        textTheme: ThemeData().textTheme.apply(
          bodyColor: AppColors.textColor,
          displayColor: AppColors.textColor,
        ),
        // InputDecorationTheme controls hint/label and border colors for input fields
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: AppColors.hintColor),
          labelStyle: TextStyle(color: AppColors.hintColor),
          floatingLabelStyle: TextStyle(color: AppColors.hintColor),
          filled: true,
          fillColor: AppColors.accentColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 12,
          ),
        ),
        // Cursor and selection colors inside text fields
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.textColor,
          selectionColor: Colors.white24,
          selectionHandleColor: AppColors.textColor,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.hintColor,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.primaryColor,
          elevation: 0,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.primaryColor,
        ),
        // Global BottomNavigationBar theme: controls icon colors and label colors centrally
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryColor,
          // Icon colors (selected vs unselected)
          selectedIconTheme: IconThemeData(
            color: AppColors.buttonColor.withAlpha(217),
            size: 36,
          ),
          unselectedIconTheme: IconThemeData(
            color: AppColors.buttonColor,
            size: 36,
          ),
          // Label text colors (selected vs unselected)
          selectedLabelStyle: TextStyle(
            color: AppColors.hintColor.withAlpha(217),
          ),
          unselectedLabelStyle: TextStyle(color: AppColors.hintColor),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: AppColors.buttonColor,
          unselectedItemColor: AppColors.hintColor,
        ),
      ),
    );
  }
}
