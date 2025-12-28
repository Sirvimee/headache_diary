import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DayView extends StatelessWidget {
  final DateTime date;
  DayView({super.key, required this.date});

  // final service = FirestoreService();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool get isFuture =>
      date.isAfter(DateTime.now().subtract(const Duration(days: 1)));

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Day View'),
    );
  }

}
