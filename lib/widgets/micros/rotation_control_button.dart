import 'package:flutter/material.dart';

class RotationControlButton extends StatelessWidget {
  const RotationControlButton({
    super.key,
    required this.onPressed, required this.isDisabled,
  });

  final bool isDisabled;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(
        Icons.navigation_rounded,
        color: isDisabled ? Colors.black38 : Colors.black,
        semanticLabel: 'Align map with the north',
        size: 40,
      ),
    );
  }
}
