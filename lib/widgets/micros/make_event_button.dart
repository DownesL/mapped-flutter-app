import 'package:flutter/material.dart';

class MakeEventButton extends StatelessWidget {
  const MakeEventButton({super.key, required this.color, required this.label, this.onPressed});

  final Color color;
  final String label;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
            ),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                side: BorderSide(
                  color: color,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            backgroundColor: MaterialStatePropertyAll(
                Theme.of(context).colorScheme.background),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
            ),
          ),
        ),
      );
  }
}
