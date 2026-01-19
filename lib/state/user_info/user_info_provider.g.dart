// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userInfoModel)
const userInfoModelProvider = UserInfoModelFamily._();

final class UserInfoModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserInfoModel>,
          UserInfoModel,
          Stream<UserInfoModel>
        >
    with $FutureModifier<UserInfoModel>, $StreamProvider<UserInfoModel> {
  const UserInfoModelProvider._({
    required UserInfoModelFamily super.from,
    required UserId super.argument,
  }) : super(
         retry: null,
         name: r'userInfoModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userInfoModelHash();

  @override
  String toString() {
    return r'userInfoModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<UserInfoModel> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserInfoModel> create(Ref ref) {
    final argument = this.argument as UserId;
    return userInfoModel(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserInfoModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userInfoModelHash() => r'0a127fdd7c5ad429e7316312d2cf6e1f0169f266';

final class UserInfoModelFamily extends $Family
    with $FunctionalFamilyOverride<Stream<UserInfoModel>, UserId> {
  const UserInfoModelFamily._()
    : super(
        retry: null,
        name: r'userInfoModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserInfoModelProvider call(UserId id) =>
      UserInfoModelProvider._(argument: id, from: this);

  @override
  String toString() => r'userInfoModelProvider';
}
