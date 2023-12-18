import 'package:flutter/material.dart';

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.color,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final Color color;
  final String label;
  final void Function()? onTap;
  final bool isSelected;

  BoxDecoration getDecoration() {
    return BoxDecoration(
      border: Border.all(color: color),
      color: isSelected ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: getDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        margin: const EdgeInsets.all(4.0),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: isSelected ? Theme.of(context).colorScheme.background : color),
        ),
      ),
    );
  }
}
