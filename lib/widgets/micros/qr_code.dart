import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCode extends StatefulWidget {
  const QRCode({super.key, this.id = 'Download Mapped!'});

  final String id;

  @override
  State<QRCode> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCode> {
  @override
  Widget build(BuildContext context) {
    final qrFutureBuilder = CustomPaint(
      size: const Size.square(280),
      painter: QrPainter(
        data: widget.id,
        version: QrVersions.auto,
        gapless: true,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Theme.of(context).primaryColor,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );

    return Material(
      color: Theme.of(context).colorScheme.background,
      child: SafeArea(
        child: Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: qrFutureBuilder,
          ),
        ),
      ),
    );
  }
}
