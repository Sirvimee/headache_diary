import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../state/constants/firebase_field_name.dart';
import '../../../widgets/svg_icon.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import 'day_action_items.dart';

class DayActionModal extends StatefulWidget {
  final DateTime date;
  const DayActionModal({super.key, required this.date});

  @override
  State<DayActionModal> createState() => _DayActionModalState();
}

class _DayActionModalState extends State<DayActionModal> {
  late final String uid;
  bool _loading = false;

  final List<ActionItem> items = actionItems;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String _fmtTitle(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return Strings.today;
    }
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<DocumentReference> _getOrCreateDayDocRef() async {
    final dateIso = widget.date.toIso8601String().substring(0, 10);
    final col = FirebaseFirestore.instance.collection('users').doc(uid).collection('days');

    final docRef = col.doc(dateIso);
    final docSnap = await docRef.get();
    if (docSnap.exists) return docRef;

    // Check for legacy doc stored with auto-id but with date field
    final q = await col.where(FirebaseFieldName.date, isEqualTo: dateIso).limit(1).get();
    if (q.docs.isNotEmpty) {
      final old = q.docs.first;
      final data = old.data();
      await docRef.set(data);
      // delete old doc to keep single source of truth
      try {
        await old.reference.delete();
      } catch (_) {}
      return docRef;
    }

    final payload = {
      FirebaseFieldName.date: dateIso,
      FirebaseFieldName.medication: {},
      FirebaseFieldName.icons: {},
      FirebaseFieldName.notes: '',
    };

    await docRef.set(payload);
    return docRef;
  }

  Future<void> _toggleIcon(String key) async {
    if (!_canEdit(key)) return;

    setState(() => _loading = true);
    try {
      final ref = await _getOrCreateDayDocRef();
      final snap = await ref.get();
      final data = snap.data() as Map<String, dynamic>? ?? {};
      final icons = Map<String, dynamic>.from(data[FirebaseFieldName.icons] ?? {});

      if (icons.containsKey(key) && icons[key] == true) {
        icons.remove(key);
        await ref.update({FirebaseFieldName.icons: icons});

        if (key == FirebaseFieldName.systal) {
          try {
            await ref.update({FirebaseFieldName.reminder: FieldValue.delete()});
          } catch (_) {}
        }
      } else {
        icons[key] = true;
        await ref.update({FirebaseFieldName.icons: icons});
      }
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _changePillCount(int delta) async {
    if (!_canEdit('pill_plus')) return;
    setState(() => _loading = true);
    try {
      final ref = await _getOrCreateDayDocRef();

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final data = snap.data() as Map<String, dynamic>? ?? {};
        final meds = Map<String, dynamic>.from(data[FirebaseFieldName.medication] ?? {});
        final current = (meds[FirebaseFieldName.pill] ?? 0) as int;
        final next = (current + delta).clamp(0, 9999);
        meds[FirebaseFieldName.pill] = next;
        tx.update(ref, {FirebaseFieldName.medication: meds});
      });
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  bool _canEdit(String key) {
    final today = DateTime.now();
    final selected = DateTime(widget.date.year, widget.date.month, widget.date.day);
    final isFuture = selected.isAfter(DateTime(today.year, today.month, today.day));
    if (isFuture && key != FirebaseFieldName.systal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.canAddOnlyToValidDates)));
      return false;
    }
    return true;
  }

  Future<void> _editNotes() async {
    if (!_canEdit(FirebaseFieldName.notes)) return;
    final controller = TextEditingController();
    final res = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(Strings.additionalNotes),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(hintText: Strings.enterAdditionalNotes),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(Strings.cancel, style: TextStyle(color: AppColors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text(Strings.save, style: TextStyle(color: AppColors.buttonColor))),
        ],
      ),
    );

    if (res == null) return;

    setState(() => _loading = true);
    try {
      final ref = await _getOrCreateDayDocRef();
      await ref.update({FirebaseFieldName.notes: res});
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  // TODO add notification
  Future<void> _addSystalForFuture() async {
    final today = DateTime.now();
    final selected = DateTime(widget.date.year, widget.date.month, widget.date.day);
    if (!selected.isAfter(DateTime(today.year, today.month, today.day))) {
      await _toggleIcon(FirebaseFieldName.systal);
      return;
    }

    setState(() => _loading = true);
    try {
      final ref = await _getOrCreateDayDocRef();
      final snap = await ref.get();
      final data = snap.data() as Map<String, dynamic>? ?? {};
      final icons = Map<String, dynamic>.from(data[FirebaseFieldName.icons] ?? {});
      icons[FirebaseFieldName.systal] = true;

      final reminderTime = DateTime(widget.date.year, widget.date.month, widget.date.day, 9, 0).toIso8601String();
      final reminder = {FirebaseFieldName.enabled: true, FirebaseFieldName.time: reminderTime};

      await ref.update({FirebaseFieldName.icons: icons, FirebaseFieldName.reminder: reminder});

    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black54),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: 0.6,
                widthFactor: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: Container(
                    color: AppColors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              _fmtTitle(widget.date),
                              style: const TextStyle(color: AppColors.textColor, fontSize: 20),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, color: AppColors.buttonColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 3,
                            childAspectRatio: 1.2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            children: items.map((it) {
                              return GestureDetector(
                                onTap: () async {
                                  if (it.key == 'pill_plus') {
                                    await _changePillCount(1);
                                  } else if (it.key == 'pill_minus') {
                                    await _changePillCount(-1);
                                  } else if (it.key == FirebaseFieldName.notes) {
                                    await _editNotes();
                                  } else if (it.key == FirebaseFieldName.systal) {
                                    await _addSystalForFuture();
                                  } else {
                                    await _toggleIcon(it.key);
                                  }
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Transform(
                                      alignment: Alignment.center,
                                      transform: it.flip ? Matrix4.rotationY(3.14159) : Matrix4.identity(),
                                      child: SvgIcon(asset: it.asset, size: 44, color: AppColors.buttonColor),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      it.label,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: AppColors.textColor, fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        if (_loading) const LinearProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
