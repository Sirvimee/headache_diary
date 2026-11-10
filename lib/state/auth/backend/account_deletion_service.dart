import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/firebase_collection_name.dart';
import '../../constants/firebase_field_name.dart';

class AccountDeletionService {
  const AccountDeletionService();

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(code: 'no-current-user');
    }

    final firestore = FirebaseFirestore.instance;
    final days = firestore
        .collection(FirebaseCollectionName.entries)
        .doc(user.uid)
        .collection(FirebaseCollectionName.days);
    final profileQuery = await firestore
        .collection(FirebaseCollectionName.users)
        .where(FirebaseFieldName.userId, isEqualTo: user.uid)
        .get();

    final documentsToDelete = <DocumentReference<Map<String, dynamic>>>[
      ...profileQuery.docs.map((document) => document.reference),
    ];

    QuerySnapshot<Map<String, dynamic>> daysSnapshot;
    do {
      daysSnapshot = await days.limit(400).get();
      documentsToDelete.addAll(
        daysSnapshot.docs.map((document) => document.reference),
      );
      if (documentsToDelete.length >= 450 || daysSnapshot.docs.isNotEmpty) {
        await _deleteBatch(documentsToDelete);
        documentsToDelete.clear();
      }
    } while (daysSnapshot.docs.isNotEmpty);

    if (documentsToDelete.isNotEmpty) {
      await _deleteBatch(documentsToDelete);
    }

    await user.delete();
  }

  Future<void> _deleteBatch(
    List<DocumentReference<Map<String, dynamic>>> documents,
  ) async {
    for (var start = 0; start < documents.length; start += 450) {
      final end = (start + 450).clamp(0, documents.length);
      final batch = FirebaseFirestore.instance.batch();
      for (final document in documents.sublist(start, end)) {
        batch.delete(document);
      }
      await batch.commit();
    }
  }
}
