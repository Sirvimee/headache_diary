import 'package:cloud_firestore/cloud_firestore.dart';

class DayEntryFirestore {
  DayEntryFirestore._();

  static CollectionReference<Map<String, dynamic>> daysCollection(String uid) =>
      FirebaseFirestore.instance.collection('entries').doc(uid).collection('days');

  static String formatDate(DateTime date) =>
      date.toIso8601String().substring(0, 10);
}
