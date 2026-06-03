import 'package:flutter/material.dart';

/// Compact previous/next arrow used in the corners of the weekday header row.
class CalendarNavButton extends StatelessWidget {
  const CalendarNavButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.width = 40,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: IconButton(
        icon: Icon(icon),
        iconSize: 22,
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
