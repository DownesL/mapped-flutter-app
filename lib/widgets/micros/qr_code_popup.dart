import 'package:flutter/material.dart';
import 'package:mapped/widgets/micros/qr_code.dart';

class QRCodePopup extends StatelessWidget {
  const QRCodePopup({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      style: ButtonStyle(
          side: MaterialStatePropertyAll(
            BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          backgroundColor: MaterialStatePropertyAll(
            Theme.of(context).colorScheme.background,
          )),
      onPressed: () => _dialogBuilder(context, url),
      icon: Icon(
        Icons.qr_code_2,
        size: 32,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _dialogBuilder(BuildContext context, String id) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: const Text('Scan Me!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QRCode(id: id),
            ],
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  textStyle: Theme.of(context).textTheme.labelLarge,
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary)),
              child: const Text('Done!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
