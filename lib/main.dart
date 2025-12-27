import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:headache_diary/router/router.dart';
import 'firebase_options.dart';
import 'views/constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.primaryColor)
        .copyWith(surface: AppColors.primaryColor);

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
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
      ),
    );
  }
}
