import 'package:flutter/material.dart';

class MansionStep extends StatelessWidget {
  const MansionStep({super.key, required this.number, required this.label, this.dark = false});
  final int number;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: [
          for (int i = 1; i <= 3; i++)
            Container(
              width: i == number ? 30 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: i == number ? const Color(0xFFF5A34D)
                    : (dark ? Colors.white38 : Colors.deepPurple.shade100),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          Text('ROOM $number OF 3  /  $label',
              style: TextStyle(
                color: dark ? Colors.white70 : const Color(0xFF543572),
                fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      );
}
