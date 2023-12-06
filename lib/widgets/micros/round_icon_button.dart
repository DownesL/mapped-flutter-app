import 'package:flutter/material.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton(
      {super.key,
      required this.icon,
      required this.label,
      required this.onTap,
      this.size = 56,
      this.backgroundColor = 0x11000000,
      this.foregroundColor = 0xFF000000});

  final IconData icon;
  final String label;
  final void Function() onTap;
  final double size;
  final int backgroundColor;
  final int foregroundColor;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ButtonStyle(
        shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(size))),
        fixedSize: MaterialStatePropertyAll(Size(size, size)),
        padding: const MaterialStatePropertyAll(EdgeInsets.all(0))
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon), Text(label)],
      ),
    );
  }
}
