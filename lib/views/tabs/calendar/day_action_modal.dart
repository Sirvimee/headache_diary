import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../state/constants/firebase_field_name.dart';
import '../../../widgets/svg_icon.dart';
import '../../constants/app_colors.dart';
import '../../constants/strings.dart';
import 'day_action_items.dart';
import '../../../state/calendar/backend/day_entry_storage.dart';
import '../../../state/auth/backend/local_storage.dart';

enum _NotesAction { save, delete }

class DayActionModal extends StatefulWidget {
  final DateTime date;
  const DayActionModal({super.key, required this.date});

  @override
  State<DayActionModal> createState() => _DayActionModalState();
}

class _DayActionModalState extends State<DayActionModal> {
  late final String uid;
  bool _loading = false;
  bool _reorderMode = false;

  List<ActionItem> items = List<ActionItem>.of(actionItems);

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _loadActionOrder();
  }

  Future<void> _loadActionOrder() async {
    final savedKeys = LocalStorage.actionOrder;
    if (savedKeys.isEmpty || !mounted) return;
    final byKey = {for (final item in actionItems) item.key: item};
    final ordered = <ActionItem>[
      for (final key in savedKeys)
        if (byKey[key] != null) byKey[key]!,
    ];
    ordered.addAll(actionItems.where((item) => !savedKeys.contains(item.key)));
    if (mounted) setState(() => items = ordered);
  }

  Future<void> _saveActionOrder() {
    return LocalStorage.saveActionOrder(items.map((item) => item.key).toList());
  }

  Future<void> _moveItem(String draggedKey, int targetIndex) async {
    final oldIndex = items.indexWhere((item) => item.key == draggedKey);
    if (oldIndex < 0 || oldIndex == targetIndex) return;
    final updated = List<ActionItem>.of(items);
    final item = updated.removeAt(oldIndex);
    updated.insert(
      targetIndex > oldIndex ? targetIndex - 1 : targetIndex,
      item,
    );
    setState(() => items = updated);
    await _saveActionOrder();
  }

  String _fmtTitle(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return Strings.today;
    }
    return '${date.day}.${date.month}.${date.year}';
  }

  Future<void> _toggleIcon(String key) async {
    if (!_canEdit(key)) return;

    setState(() => _loading = true);
    try {
      await DayEntryStorage().toggleIcon(widget.date, key);
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
      await DayEntryStorage().changePillCount(widget.date, delta);
    } catch (e) {
      // ignore
    } finally {
      setState(() => _loading = false);
    }
  }

  bool _canEdit(String key) {
    final today = DateTime.now();
    final selected = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );
    final isFuture = selected.isAfter(
      DateTime(today.year, today.month, today.day),
    );
    if (isFuture &&
        key != FirebaseFieldName.systal &&
        key != FirebaseFieldName.doctor &&
        key != FirebaseFieldName.preventivePill) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(Strings.canAddOnlyToValidDates)));
      return false;
    }
    return true;
  }

  bool _isFutureDate() {
    final today = DateTime.now();
    final selected = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
    );
    return selected.isAfter(DateTime(today.year, today.month, today.day));
  }

  Future<TimeOfDay?> _pickReminderTime() {
    return showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 12, minute: 0),
    );
  }

  Future<void> _addScheduledIcon(String key) async {
    if (!_canEdit(key)) return;
    final current = await DayEntryStorage().dayEntryStream(widget.date).first;
    if (current?.icons[key] == true) {
      setState(() => _loading = true);
      try {
        await DayEntryStorage().addFutureReminder(
          date: widget.date,
          iconKey: key,
          reminderDate: widget.date,
          title: '',
          body: '',
        );
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(Strings.reminderScheduleFailedSnackBar)),
          );
        }
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }
    if (!mounted) return;
    final controller = TextEditingController();
    final isDoctor = key == FirebaseFieldName.doctor;
    final name = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isDoctor ? Strings.doctorName : Strings.pillName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isDoctor
                ? Strings.enterDoctorName
                : Strings.enterPillName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Strings.cancel,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(
              Strings.next,
              style: TextStyle(color: AppColors.buttonColor),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (name == null || name.isEmpty) return;

    String? grams;
    if (!isDoctor) {
      final gramsController = TextEditingController();
      grams = await showDialog<String?>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(Strings.pillGrams),
          content: TextField(
            controller: gramsController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(hintText: Strings.enterPillGrams),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                Strings.cancel,
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, gramsController.text.trim()),
              child: Text(
                Strings.save,
                style: TextStyle(color: AppColors.buttonColor),
              ),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (grams == null || double.tryParse(grams) == null) {
        if (grams != null && mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(Strings.invalidPillGrams)));
        }
        return;
      }
    }

    final time = await _pickReminderTime();
    if (!mounted) return;
    if (time == null) return;
    final reminderDate = DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      time.hour,
      time.minute,
    );
    setState(() => _loading = true);
    try {
      final status = await DayEntryStorage().addFutureReminder(
        date: widget.date,
        iconKey: key,
        reminderDate: reminderDate,
        title: isDoctor ? Strings.doctor : Strings.preventivePill,
        body: isDoctor
            ? '${Strings.doctorNotificationBody}: $name'
            : '${Strings.pillNotificationBody}: $name',
        details: isDoctor
            ? {FirebaseFieldName.doctorName: name}
            : {
                FirebaseFieldName.preventivePillName: name,
                FirebaseFieldName.preventivePillGrams: double.parse(grams!),
              },
      );
      if (mounted && status == 1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Strings.reminderAddedSnackBar)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Strings.reminderScheduleFailedSnackBar)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editNotes() async {
    if (!_canEdit(FirebaseFieldName.notes)) return;
    final currentEntry = await DayEntryStorage()
        .dayEntryStream(widget.date)
        .first;
    if (!mounted) return;

    final controller = TextEditingController(text: currentEntry?.notes ?? '');
    final action = await showDialog<_NotesAction>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(Strings.additionalNotes),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(hintText: Strings.enterAdditionalNotes),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Strings.cancel,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _NotesAction.delete),
            child: Text(Strings.delete, style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _NotesAction.save),
            child: Text(
              Strings.save,
              style: TextStyle(color: AppColors.buttonColor),
            ),
          ),
        ],
      ),
    );

    if (action == null) return;
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      if (action == _NotesAction.delete) {
        await DayEntryStorage().deleteNotes(widget.date);
      } else {
        await DayEntryStorage().editNotes(widget.date, controller.text);
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _askText(String title, String hint) async {
    final controller = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Strings.cancel,
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(
              Strings.save,
              style: TextStyle(color: AppColors.buttonColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPreventiveMedication({required bool injection}) async {
    final iconKey = injection
        ? FirebaseFieldName.systal
        : FirebaseFieldName.preventivePill;
    final current = await DayEntryStorage().dayEntryStream(widget.date).first;
    if (current?.icons[iconKey] == true) {
      setState(() => _loading = true);
      try {
        await DayEntryStorage().toggleIcon(widget.date, iconKey);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
      return;
    }
    final name = await _askText(
      injection ? Strings.injectionName : Strings.pillName,
      injection ? Strings.enterInjectionName : Strings.enterPillName,
    );
    if (!mounted || name == null || name.isEmpty) return;
    final mgText = await _askText(
      injection ? Strings.injectionMg : Strings.pillGrams,
      injection ? Strings.enterInjectionMg : Strings.enterPillGrams,
    );
    final mg = double.tryParse(mgText ?? '');
    if (!mounted || mg == null || mg <= 0) {
      if (mgText != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Strings.invalidPillGrams)));
      }
      return;
    }

    DateTime? endDate;
    if (!injection) {
      endDate = await showDatePicker(
        context: context,
        initialDate: widget.date,
        firstDate: widget.date,
        lastDate: DateTime(2100),
        helpText: Strings.treatmentEndDate,
      );
      if (!mounted) return;
    }

    DateTime? reminderDate;
    if (_isFutureDate()) {
      final time = await _pickReminderTime();
      if (!mounted || time == null) return;
      reminderDate = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        time.hour,
        time.minute,
      );
    }

    setState(() => _loading = true);
    try {
      final status = await DayEntryStorage().addPreventiveMedication(
        date: widget.date,
        iconKey: iconKey,
        name: name,
        milligrams: mg,
        endDate: endDate,
        reminderDate: reminderDate,
        title: injection ? Strings.injection : Strings.preventivePill,
        body: injection
            ? '${Strings.notificationBody}: $name'
            : '${Strings.pillNotificationBody}: $name',
      );
      if (!mounted) return;
      if (status == 1) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Strings.reminderAddedSnackBar)));
      } else if (status == 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Strings.failedToScheduleReminderSnackBar)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Strings.reminderScheduleFailedSnackBar)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addInjections() async {
    await _addPreventiveMedication(injection: true);
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  child: Container(
                    color: AppColors.black,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Text(
                              _fmtTitle(widget.date),
                              style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: 20,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: _reorderMode
                                        ? Strings.finishReorderingIcons
                                        : Strings.reorderIcons,
                                    onPressed: () => setState(
                                      () => _reorderMode = !_reorderMode,
                                    ),
                                    icon: Icon(
                                      _reorderMode
                                          ? Icons.check
                                          : Icons.swap_vert,
                                      color: AppColors.buttonColor,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(
                                      Icons.close,
                                      color: AppColors.buttonColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Expanded(
                          child: GridView.builder(
                            itemCount: items.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                            itemBuilder: (context, index) {
                              final it = items[index];
                              final tile = GestureDetector(
                                onTap: _reorderMode
                                    ? null
                                    : () async {
                                        if (it.key == 'pill_plus') {
                                          await _changePillCount(1);
                                        } else if (it.key == 'pill_minus') {
                                          await _changePillCount(-1);
                                        } else if (it.key ==
                                            FirebaseFieldName.notes) {
                                          await _editNotes();
                                        } else if (it.key ==
                                            FirebaseFieldName.systal) {
                                          await _addInjections();
                                        } else if (it.key ==
                                            FirebaseFieldName.preventivePill) {
                                          await _addPreventiveMedication(
                                            injection: false,
                                          );
                                        } else if (it.key ==
                                                FirebaseFieldName.doctor &&
                                            _isFutureDate()) {
                                          await _addScheduledIcon(it.key);
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
                                      transform: it.flip
                                          ? Matrix4.rotationY(3.14159)
                                          : Matrix4.identity(),
                                      child: SvgIcon(
                                        asset: it.asset,
                                        size: 44,
                                        color: AppColors.buttonColor,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      it.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textColor,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                              if (!_reorderMode) return tile;
                              return DragTarget<String>(
                                onWillAcceptWithDetails: (_) => true,
                                onAcceptWithDetails: (details) =>
                                    _moveItem(details.data, index),
                                builder: (context, candidate, rejected) {
                                  return LongPressDraggable<String>(
                                    data: it.key,
                                    feedback: Material(
                                      color: Colors.transparent,
                                      child: SizedBox(width: 100, child: tile),
                                    ),
                                    childWhenDragging: Opacity(
                                      opacity: 0.3,
                                      child: tile,
                                    ),
                                    child: tile,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        if (_loading) LinearProgressIndicator(),
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
