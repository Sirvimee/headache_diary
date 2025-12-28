import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class SvgIcon extends StatelessWidget {
  final String asset;
  final double size;
  final Color color;

  const SvgIcon({
    super.key,
    required this.asset,
    this.size = 24,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
