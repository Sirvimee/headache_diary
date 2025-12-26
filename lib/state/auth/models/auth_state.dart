import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../typedef/user_id.dart';
import 'auth_result.dart';

part 'auth_state.freezed.dart';

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    required AuthResult? result,
    required bool isLoading,
    required UserId? userId,
  }) = _AuthState;

  const AuthState._();

  factory AuthState.unknown() => const AuthState(
    result: null,
    isLoading: false,
    userId: null,
  );
}
