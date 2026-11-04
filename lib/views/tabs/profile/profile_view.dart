import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../authentication/validators/validators.dart';
import '../../constants/strings.dart';
import '../../../state/user_info/backend/user_info_storage.dart';
import '../../constants/app_colors.dart';
import '../../../state/auth/models/auth_result.dart';
import '../../../state/auth/providers/authentication_provider.dart';

class ProfileContent extends ConsumerStatefulWidget {
  const ProfileContent({super.key});

  @override
  ProfileContentState createState() => ProfileContentState();
}

class ProfileContentState extends ConsumerState<ProfileContent> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _passwordFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();

  var _isLoading = false;

  Future<void> _chooseColorTheme() async {
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Strings.chooseColorTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < AppColors.themes.length; i++)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.themes[i].button,
                ),
              title: Text(
                AppColors.themes[i].name,
                style: TextStyle(color: AppColors.themes[i].hint),
              ),
              selected: AppColors.theme.value == i,
              onTap: () => Navigator.pop(context, i),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 0),
            child: Text(
              Strings.resetColorTheme,
              style: TextStyle(color: AppColors.buttonColor),
            ),
          ),
        ],
      ),
    );
    if (selected != null) await AppColors.setTheme(selected);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _attemptToChangePassword() async {
    final form = _passwordFormKey.currentState;
    if (form == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Strings.formNotAvailable)));
      return;
    }
    if (!form.validate()) return;

    setState(() => _isLoading = true);

    final enteredEmail = _emailController.text.trim();
    final newPassword = _passwordController.text;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Strings.userNotFound)));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final currentEmail = user.email ?? '';

    if (enteredEmail != currentEmail) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Strings.wrongEmailAddress)));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Try to update the password in Firebase Auth
    try {
      await (user as dynamic).updatePassword(newPassword);
      if (!mounted) return;
      if (mounted) context.push('/data-changed');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = e.message ?? e.code;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${Strings.errorMessage} $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _attemptToChangeUsername() async {
    setState(() => _isLoading = true);

    final newName = _nameController.text.trim();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Strings.userNotFound)));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final storage = UserInfoStorage();
      await storage.saveUserInfo(
        userId: user.uid,
        displayName: newName,
        email: user.email,
      );
      if (!mounted) return;
      if (mounted) context.push('/data-changed');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${Strings.errorMessage} $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGuest =
        ref.watch(authenticationProvider).result == AuthResult.local;

    return SafeArea(
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
                    OutlinedButton.icon(
                      onPressed: _chooseColorTheme,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.buttonColor,
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.buttonColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(Icons.palette_outlined),
                      label: Text(Strings.appColors),
                    ),
                    SizedBox(height: 20),
                    if (!isGuest) ...[
                      Text(
                      Strings.changePassword,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),

                    Form(
                      key: _passwordFormKey,
                      child: Column(
                        children: [

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
                              onPressed: _isLoading ? null : _attemptToChangePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: AppColors.textColor, strokeWidth: 2),
                                    )
                                  : Text(
                                      Strings.change,
                                      style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),

                          SizedBox(height: 16),
                        ],
                      ),
                    ),

                    SizedBox(height: 24),

                    // Change name section
                    Text(
                      Strings.changeUsername,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 20),

                    Form(
                      key: _nameFormKey,
                      child: Column(
                        children: [
                          // New name
                          SizedBox(
                            height: 60,
                            child: TextFormField(
                              controller: _nameController,
                              // username should not be obscured
                              obscureText: false,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: Strings.newUsername,
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _attemptToChangeUsername,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: AppColors.textColor, strokeWidth: 2),
                              )
                                  : Text(
                                Strings.change,
                                style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),

                          SizedBox(height: 16),
                        ],
                      ),
                    ),

                    ],
                    Spacer(),
                  ],
                ),
              ),
            ));
          },
        ),
      );
  }
}
