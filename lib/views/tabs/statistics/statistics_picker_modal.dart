import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../constants/app_colors.dart';
import '../../constants/strings.dart';

class StatisticsPickerModal extends StatefulWidget {
  const StatisticsPickerModal({super.key});

  @override
  State<StatisticsPickerModal> createState() => _StatisticsPickerModalState();
}

class _StatisticsPickerModalState extends State<StatisticsPickerModal> {
  bool _period = false;
  DateTime? _start;
  DateTime? _end;

  final _dateFormat = DateFormat('dd.MM.yyyy');

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final initial = _start ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => child ?? const SizedBox.shrink(),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final now = DateTime.now();
    final initial = _end ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => child ?? const SizedBox.shrink(),
    );
    if (picked != null) setState(() => _end = picked);
  }

  bool get _periodValid => _start != null && _end != null && !_end!.isBefore(_start!);

  void _confirm() {
    if (!_period) {
      Navigator.of(context).pop({'mode': 'monthly'});
      return;
    }

    if (!_periodValid) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(Strings.pickCorrectDateRange)));
      return;
    }

    Navigator.of(context).pop({'mode': 'period', 'start': _start, 'end': _end});
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
                heightFactor: 0.5,
                widthFactor: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  child: Container(
                    color: AppColors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Text(
                              Strings.pickPeriod,
                              style: TextStyle(color: AppColors.textColor, fontSize: 20),
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
                        RadioListTile<bool>(
                          value: false,
                          groupValue: _period,
                          onChanged: (v) => setState(() => _period = v ?? false),
                          title: const Text(Strings.byMonth, style: TextStyle(color: AppColors.textColor)),
                          activeColor: AppColors.buttonColor,
                        ),
                        RadioListTile<bool>(
                          value: true,
                          groupValue: _period,
                          onChanged: (v) => setState(() => _period = v ?? true),
                          title: const Text(Strings.byPeriod, style: TextStyle(color: AppColors.textColor)),
                          activeColor: AppColors.buttonColor,
                        ),
                        if (_period) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickStart,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF121212),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade800),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(Strings.from, style: TextStyle(color: AppColors.grey, fontSize: 12)),
                                        const SizedBox(height: 6),
                                        Text(
                                          _start != null ? _dateFormat.format(_start!) : Strings.pickDate,
                                          style: const TextStyle(color: AppColors.textColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickEnd,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF121212),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade800),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(Strings.to, style: TextStyle(color: AppColors.grey, fontSize: 12)),
                                        const SizedBox(height: 6),
                                        Text(
                                          _end != null ? _dateFormat.format(_end!) : Strings.pickDate,
                                          style: const TextStyle(color: AppColors.textColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Spacer(),
                        ElevatedButton(
                          onPressed: (_period && !_periodValid) ? null : _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(Strings.confirm, style: TextStyle(color: AppColors.primaryColor)),
                        ),
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
