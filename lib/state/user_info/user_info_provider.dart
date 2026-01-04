import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../typedef/user_id.dart';
import '../constants/firebase_field_name.dart';
import '../constants/firebase_collection_name.dart';
import 'models/user_info_model.dart';

part 'user_info_provider.g.dart';

@riverpod
Stream<UserInfoModel> userInfoModel(Ref ref, UserId id) {
  return FirebaseFirestore.instance
      .collection(FirebaseCollectionName.users)
      .where(FirebaseFieldName.userId, isEqualTo: id)
      .limit(1)
      .snapshots()
      .where((snapshot) => snapshot.docs.isNotEmpty)
      .map((snapshot) {
    final doc = snapshot.docs.first;
    return UserInfoModel.fromJson(doc.data());
  });
}
