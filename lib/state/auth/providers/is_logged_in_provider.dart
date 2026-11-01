import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_result.dart';
import 'authentication_provider.dart';

part 'is_logged_in_provider.g.dart';

@riverpod
bool isLoggedIn(Ref ref) {
  final authProvider = ref.watch(authenticationProvider);
  return authProvider.result == AuthResult.success ||
      authProvider.result == AuthResult.local;
}
