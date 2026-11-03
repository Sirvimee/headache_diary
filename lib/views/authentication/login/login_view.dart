import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:headache_diary/state/auth/models/auth_result.dart';
import 'package:headache_diary/state/auth/models/auth_state.dart';
import 'package:headache_diary/state/auth/providers/authentication_provider.dart';
import 'package:headache_diary/views/constants/app_colors.dart';
import 'package:headache_diary/views/constants/strings.dart';

import '../validators/validators.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  LoginViewState createState() => LoginViewState();
}

class LoginViewState extends ConsumerState<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    final formState = _formKey.currentState;
    if (formState == null) {
      // Form not mounted yet; show an error and return safely
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Strings.formNotAvailable)));
      return;
    }

    if (!formState.validate()) {
      // validation failed; do not proceed
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final authProvider = ref.read(authenticationProvider.notifier);
      await authProvider.loginWithEmailAndPassword(email, password);

      // Check latest auth state after attempting login
      final current = ref.read(authenticationProvider);
      if (current.result != AuthResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.invalidEmailOrPassword),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${Strings.loginFailed}$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = ref.watch(authenticationProvider);

    ref.listen(authenticationProvider, (
      AuthState? previous,
      AuthState current,
    ) {
      if (current.result == AuthResult.failure && !current.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Strings.invalidEmailOrPassword),
            backgroundColor: AppColors.red,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 70,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 36),
                      // Title
                      Text(
                        Strings.appName,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 36,
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32),

                      // Google sign-in button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () async {
                                  // Call provider's Google sign-in which integrates with Firebase
                                  await ref
                                      .read(authenticationProvider.notifier)
                                      .loginWithGoogle();
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/google.svg',
                                width: 32,
                                height: 32,
                              ),
                              SizedBox(width: 12),
                              Text(
                                Strings.signInWithGoogle,
                                style: TextStyle(
                                  color: AppColors.textColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 30),

                      // Divider with "või"
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: AppColors.hintColor,
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              Strings.or,
                              style: TextStyle(color: AppColors.hintColor),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: AppColors.hintColor,
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 30),

                      // Form with Email, Password and Login button
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email input
                            SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: _emailController,
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                  hintText: Strings.emailAddress,
                                ),
                                validator: (value) => validateEmail(value),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Password input
                            SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                  hintText: Strings.password,
                                ),
                                validator: (value) => validatePassword(value),
                              ),
                            ),

                            SizedBox(height: 28),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _attemptLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttonColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: authProvider.isLoading
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.textColor,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        Strings.logIntoYourAccount,
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Register and Forgot password links
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => context.push('/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.hintColor,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                            ),
                            child: Text(
                              Strings.signUp,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/change-password'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.hintColor,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                            ),
                            child: Text(
                              Strings.forgotPassword,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),

                      // Login as guest button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : () => ref
                              .read(authenticationProvider.notifier)
                              .continueWithoutLogin(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                Strings.continueWithoutLogin,
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Text(
                        Strings.guestLoginWarning,
                        style: TextStyle(color: AppColors.hintColor),
                        textAlign: TextAlign.center,
                      ),

                      Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
