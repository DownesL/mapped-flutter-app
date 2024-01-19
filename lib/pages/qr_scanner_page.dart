import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mapped/firebase_service.dart';
import 'package:mapped/models/event.dart';
import 'package:mapped/models/mapped_user.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<StatefulWidget> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  String? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var fS = FirebaseService();

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 5, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 16,
                  ),
                  if (result != null)
                    Text(result!)
                  else
                    const Text('Scan a code'),
                  const SizedBox(
                    width: 16,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      await controller.pauseCamera();
      if (scanData.format == BarcodeFormat.qrcode && scanData.code != null) {
        if (scanData.code!.startsWith(RegExp('events|users'))) {
          var index = scanData.code!.indexOf('/');
          if (index == 5) {
            var user = await fS.getUserByID(scanData.code!.substring(index));
            if (user != null && mounted) {
              Navigator.popAndPushNamed(
                context,
                '/home/event',
                arguments: UserArguments(
                  mUser: user,
                ),
              );
            } else {
              setState(() {
                result = "User not found :(";
              });
              return;
            }
          } else if (index == 6) {
            var event = await fS.getEventByID(scanData.code!.substring(index));
            if (event != null && mounted) {
              Navigator.popAndPushNamed(
                context,
                '/home/event',
                arguments: EventArguments(
                  event: event,
                ),
              );
            } else {
              setState(() {
                result = "Event not found :(";
              });
              return;
            }
          }
        }

        setState(() {
          result = "QR-code doesn't belong to app";
        });
      }

      await controller.resumeCamera();
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
