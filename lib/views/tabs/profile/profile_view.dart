import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../authentication/validators/validators.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import '../../../state/user_info/backend/user_info_storage.dart';

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
  final _currentPasswordForEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _confirmNewEmailController = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _nameFormKey = GlobalKey<FormState>();

  var _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordForEmailController.dispose();
    _newEmailController.dispose();
    _confirmNewEmailController.dispose();
    super.dispose();
  }

  Future<void> _attemptToChangePassword() async {
    final form = _passwordFormKey.currentState;
    if (form == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.formNotAvailable)));
      return;
    }
    if (!form.validate()) return;

    setState(() => _isLoading = true);

    final enteredEmail = _emailController.text.trim();
    final newPassword = _passwordController.text;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.userNotFound)));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final currentEmail = user.email ?? '';

    if (enteredEmail != currentEmail) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.wrongEmailAddress)));
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

  // TODO fix this, changing email not working properly currently
  Future<void> _attemptToChangeEmail() async {
    final form = _emailFormKey.currentState;
    if (form == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.formNotAvailable)));
      return;
    }
    if (!form.validate()) return;

    setState(() => _isLoading = true);

    final password = _currentPasswordForEmailController.text;
    final newEmail = _newEmailController.text.trim();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.userNotFound)));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(email: user.email!, password: password);
      final reauthResult = await user.reauthenticateWithCredential(credential);

      final updatedUser = reauthResult.user ?? FirebaseAuth.instance.currentUser;

      if (updatedUser == null) {
        throw FirebaseAuthException(code: 'user-not-found', message: 'User not found after reauthentication');
      }

      await (updatedUser as dynamic).updateEmail(newEmail);

      final storage = const UserInfoStorage();
      await storage.updateUserEmail(userId: updatedUser.uid, email: newEmail);

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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.userNotFound)));
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final storage = const UserInfoStorage();
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
                    const SizedBox(height: 8),
                    Text(
                      Strings.changePassword,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

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

                          const SizedBox(height: 16),

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

                          const SizedBox(height: 16),

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

                          const SizedBox(height: 24),

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
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: AppColors.textColor, strokeWidth: 2),
                                    )
                                  : const Text(
                                      Strings.change,
                                      style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Change email section
                    Text(
                      Strings.changeEmailAddress,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    Form(
                      key: _emailFormKey,
                      child: Column(
                        children: [
                          // Current password
                          SizedBox(
                            height: 60,
                            child: TextFormField(
                              controller: _currentPasswordForEmailController,
                              obscureText: true,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: Strings.password,
                              ),
                              validator: (value) => validatePassword(value),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // New email
                          SizedBox(
                            height: 60,
                            child: TextFormField(
                              controller: _newEmailController,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: Strings.newEmailAddress,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => validateEmail(value),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Confirm new email
                          SizedBox(
                            height: 60,
                            child: TextFormField(
                              controller: _confirmNewEmailController,
                              style: TextStyle(fontSize: 20),
                              decoration: InputDecoration(
                                hintText: Strings.repeatEmailAddress,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => value == _newEmailController.text ? null : Strings.emailAddressesDoNotMatch,
                            ),
                          ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            height: 70,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _attemptToChangeEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.buttonColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: AppColors.textColor, strokeWidth: 2),
                                    )
                                  : const Text(
                                      Strings.change,
                                      style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w600),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Change name section
                    Text(
                      Strings.changeUsername,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

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

                          const SizedBox(height: 16),

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
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: AppColors.textColor, strokeWidth: 2),
                              )
                                  : const Text(
                                Strings.change,
                                style: TextStyle(color: AppColors.primaryColor, fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),

                    const Spacer(),

                  ],
                ),
              ),
            ));
          },
        ),
      );
  }
}
