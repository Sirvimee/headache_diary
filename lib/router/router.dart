import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../views/auth_view.dart';
import '../views/authentication/login/change_password_view.dart';
import '../views/authentication/login/password_sent_view.dart';
import '../views/authentication/register/register_view.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const AuthView();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) {
        return const RegisterView();
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (BuildContext context, GoRouterState state) {
        return const ChangePasswordView();
      },
    ),
    GoRoute(
      path: '/password-sent',
      builder: (BuildContext context, GoRouterState state) {
        return const PasswordSentView();
      },
    ),
  ],
);
