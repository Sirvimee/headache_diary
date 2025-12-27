import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../user_info/backend/user_info_storage.dart';
import '../backend/authenticator.dart';
import '../models/auth_result.dart';
import '../models/auth_state.dart';

part 'authentication_provider.g.dart';

@riverpod
class Authentication extends _$Authentication {
  final _authenticator = const Authenticator();
  final _userInfoStorage = const UserInfoStorage();

  @override
  AuthState build() {
    if (_authenticator.isAlreadyLoggedIn) {
      return AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
    return AuthState.unknown();
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(isLoading: true);

    final result =
    await _authenticator.loginWithEmailAndPassword(email, password);

    // Simulate a network request on slow environments
    //await Future.delayed(const Duration(seconds: 3));

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> logOut() async {
    await _authenticator.logOut();
    state = AuthState.unknown();
  }

  Future<void> registerWithEmailAndPassword(
      {required String name,
        required String email,
        required String password}) async {
    state = state.copyWith(isLoading: true);

    final result =
    await _authenticator.registerWithEmailAndPassword(email, password);

    // Ensure currentUser is refreshed
    try {
      await FirebaseAuth.instance.currentUser?.reload();
    } catch (_) {}

    final userId = _authenticator.userId;

    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(userId, email, name);
    }

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true);

    final result = await _authenticator.signInWithGoogle();

    final userId = _authenticator.userId;

    // If sign in succeeded and we have a userId, try to save user info (email/name may be null)
    if (result == AuthResult.success && userId != null) {
      // Try to save user info if possible. Authenticator/GoogleSignIn user info retrieval
      // isn't implemented here; keep it simple and pass nulls where not available.
      await saveUserInfo(userId, FirebaseAuth.instance.currentUser?.email ?? '',
          FirebaseAuth.instance.currentUser?.displayName ?? '');
    }

    state = AuthState(
      result: result,
      isLoading: false,
      userId: _authenticator.userId,
    );
  }

  Future<void> saveUserInfo(String userId, String email, String name) {
    return _userInfoStorage.saveUserInfo(
      userId: userId,
      displayName: name,
      email: email,
    );
  }
}