import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../typedef/user_id.dart';
import '../../constants/firebase_collection_name.dart';
import '../../constants/firebase_field_name.dart';
import '../models/user_info_payload.dart';

class UserInfoStorage {
  const UserInfoStorage();

  Future<bool> saveUserInfo({
    required UserId userId,
    required String displayName,
    required String? email,
  }) async {
    try {
      var userInfo = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .where(FirebaseFieldName.userId, isEqualTo: userId)
          .limit(1)
          .get();

      if (userInfo.docs.isNotEmpty) {
        // we already have this user's profile, save the new data instead
        await userInfo.docs.first.reference.update({
          FirebaseFieldName.displayName: displayName,
          FirebaseFieldName.email: email ?? '',
        });
        return true;
      }

      final payload = UserInfoPayload(
          userId: userId, displayName: displayName, email: email);

      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .add(payload);

      return true;
    } catch (_) {
      return false;
    }
  }

  /// Update only the email field for the user identified by [userId].
  /// Tries doc(userId).update first (when doc id == uid), then falls back to query-by-field.
  Future<bool> updateUserEmail({
    required UserId userId,
    required String email,
  }) async {
    try {
      final usersCol = FirebaseFirestore.instance.collection(FirebaseCollectionName.users);

      // Fast path: if documents are stored with doc id == userId, try updating directly
      try {
        await usersCol.doc(userId).update({FirebaseFieldName.email: email});
        debugPrint('updateUserEmail: updated document by doc(id=$userId)');
        return true;
      } catch (e) {
        // If document doesn't exist, we'll fallback to query-by-field
        debugPrint('updateUserEmail: doc(userId) update failed, will try query-by-field: $e');
      }

      // Fallback: search by uid field
      final userInfo = await usersCol.where(FirebaseFieldName.userId, isEqualTo: userId).limit(1).get();

      if (userInfo.docs.isNotEmpty) {
        await userInfo.docs.first.reference.update({FirebaseFieldName.email: email});
        debugPrint('updateUserEmail: updated document by query');
        return true;
      }

      // No existing user doc — create one with empty displayName
      final payload = UserInfoPayload(userId: userId, displayName: '', email: email);
      await usersCol.add(payload);
      debugPrint('updateUserEmail: created new user doc');
      return true;
    } catch (e, st) {
      debugPrint('updateUserEmail failed: $e\n$st');
      return false;
    }
  }
}