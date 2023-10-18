import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:manga/main.dart';
import 'package:manga/remote.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:web_socket_channel/io.dart';

// ignore: must_be_immutable
class QRScanner extends StatefulWidget {
  static String ip = "";
  final Function(int index) callback;
  const QRScanner(this.callback, {super.key});
  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

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

  ButtonStyle getButtonStyle() {
    return ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith(
          (states) => const Color.fromARGB(255, 209, 174, 255)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text(
                        'Loại QR: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  else
                    const Text(
                      'Quét mã đi',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color.fromARGB(255, 173, 96, 7)),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            style: getButtonStyle(),
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  if (snapshot.data! == true) {
                                    return const Text('Flash: bật');
                                  }
                                }
                                return const Text('Flash: tắt');
                              },
                            )),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                            style: getButtonStyle(),
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  if (describeEnum(snapshot.data!) == "back") {
                                    return const Text(
                                      'Camera sau',
                                    );
                                  }
                                  return const Text("Camera trước");
                                } else {
                                  return const Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: getButtonStyle(),
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          child: const Text('Dừng',
                              style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: ElevatedButton(
                          style: getButtonStyle(),
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          child: const Text('Tiếp tục',
                              style: TextStyle(fontSize: 16)),
                        ),
                      )
                    ],
                  ),
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
        ? 300.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: const Color.fromARGB(255, 209, 174, 255),
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
    controller.scannedDataStream.listen((scanData) {
      if (describeEnum(scanData.format) == "qrcode") {
        setState(() {
          result = scanData;
          String data = scanData.code.toString();
          QRScanner.ip = data;
          Remote.channel = IOWebSocketChannel.connect("ws://$data:8080");
          controller.dispose();
          jumpToRemote();
        });
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  void jumpToRemote() {
    MangaApp.pageController.animateToPage(
      1,
      duration: const Duration(
          milliseconds: 500), // Điều chỉnh thời gian chuyển trang (tùy chọn)
      curve: Curves.ease, // Điều chỉnh hiệu ứng chuyển trang (tùy chọn)
    );
    widget.callback(1);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
