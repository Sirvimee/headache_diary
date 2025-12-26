import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../typedef/user_id.dart';
import 'authentication_provider.dart';

part 'user_id_provider.g.dart';

@riverpod
UserId? userId(Ref ref) {
  return ref.watch(authenticationProvider).userId;
}
