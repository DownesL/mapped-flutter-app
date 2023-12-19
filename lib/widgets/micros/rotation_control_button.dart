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
    return IconButton.outlined(
      style: ButtonStyle(
        side: MaterialStatePropertyAll(
          BorderSide(color: isDisabled
              ? Theme.of(context).colorScheme.primary.withOpacity(.5)
              : Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
      onPressed: isDisabled ? null : onPressed,
      icon: Icon(
        Icons.navigation_rounded,
        color: isDisabled ? Theme.of(context).colorScheme.primary.withOpacity(.5) : Theme.of(context).colorScheme.primary,
        semanticLabel: 'Align map with the north',
        size: 40,
      ),
    );
  }
}
