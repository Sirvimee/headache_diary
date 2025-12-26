import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth/providers/is_logged_in_provider.dart';
import 'authentication/login/login_view.dart';
import 'main/main_view.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final isLoggedIn = ref.watch(isLoggedInProvider);
      print('isLoggedIn: $isLoggedIn');
      if (isLoggedIn) {
        return const MainView();
      } else {
        return const LoginView();
      }
    });
  }
}