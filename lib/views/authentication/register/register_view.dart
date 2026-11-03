import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../state/auth/models/auth_result.dart';
import '../../../state/auth/models/auth_state.dart';
import '../../../state/auth/providers/authentication_provider.dart';
import '../../../state/auth/providers/is_logged_in_provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import '../validators/validators.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends ConsumerState<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _attemptRegister() async {
    final formState = _formKey.currentState;
    if (formState == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.formNotAvailable)),
      );
      return;
    }

    if (!formState.validate()) {
      return;
    }

    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Strings.passwordsDoNotMatch)),
      );
      return;
    }

    try {
      final authProvider = ref.read(authenticationProvider.notifier);
      await authProvider.registerWithEmailAndPassword(email: email, name: name, password: password);
      final current = ref.read(authenticationProvider);
      if (current.result != AuthResult.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Strings.userRegistrationFailed), backgroundColor: AppColors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${Strings.userRegistrationFailed}$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the user has registered successfully, we pop the current view
    ref.listen(isLoggedInProvider, (_, isLoggedIn) => context.pop());

    ref.listen(authenticationProvider,
            (AuthState? previous, AuthState current) {
          // We check if the state is not loading and login failed
          if (current.result == AuthResult.userAlreadyExists &&
              !current.isLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(Strings.userEmailAlreadyInUse),
                backgroundColor: AppColors.red,
              ),
            );
          }
        });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(Strings.back)
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),
                      Text(
                        Strings.signUp,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.textColor,
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [

                            // Username
                            SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: _nameController,
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                  hintText: Strings.username,
                                ),
                                validator: (value) => validateName(value),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Email
                            SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: _emailController,
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                  hintText: Strings.emailAddress,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => validateEmail(value),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Password
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

                            SizedBox(height: 16),

                            // Confirm password
                            SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                style: TextStyle(fontSize: 20),
                                decoration: InputDecoration(
                                  hintText: Strings.repeatPassword,
                                ),
                                validator: (value) => value == _passwordController.text ? null : Strings.passwordsDoNotMatch,
                              ),
                            ),

                            SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              height: 70,
                              child: ElevatedButton(
                                onPressed: _attemptRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.buttonColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                child: Text(
                                  Strings.signUp,
                                  style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),

                            SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // Push remaining space to avoid tight bottom
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