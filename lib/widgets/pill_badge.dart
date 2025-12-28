import 'package:flutter/material.dart';
import 'svg_icon.dart';

class PillWithCount extends StatelessWidget {
  final int count;
  const PillWithCount({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const SvgIcon(asset: 'assets/icons/pill.svg', size: 12),
        Positioned(
          right: -6,
          top: -6,
          child: CircleAvatar(
            radius: 7,
            backgroundColor: Colors.red,
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 9, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class InjectionWithClock extends StatelessWidget {
  final bool hasReminder;
  const InjectionWithClock({super.key, required this.hasReminder});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const SvgIcon(
          asset: 'assets/icons/injection.svg',
          size: 12,
          color: Colors.redAccent,
        ),
        if (hasReminder)
          const Positioned(
            right: -4,
            bottom: -4,
            child: Icon(Icons.schedule, size: 8),
          ),
      ],
    );
  }
}
