import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector({super.key, required this.color, required this.action, required this.label});

  final Color color;
  final void Function() action;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration:
          BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        OutlinedButton(
          onPressed: action,
          child: Text(label),
        ),
      ],
    );
  }
}
