import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';

class CameraScreen extends StatefulWidget {
  static const String id = 'camera_screen';

  const CameraScreen({
    required this.onBarcodeScan,
  });

  final Future<TaskOperation> Function(String) onBarcodeScan;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  MobileScannerController cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kGreyBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kPrimaryColor,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const FaIcon(
                  FontAwesomeIcons.angleLeft,
                  color: kPrimaryColorLight,
                ),
              ),
              const SizedBox(
                width: 15.0,
              ),
              Text(
                'Scanner Câmara',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: kPrimaryColorLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          elevation: 10,
        ),
        body: MobileScanner(
          controller: cameraController,
          onDetect: (BarcodeCapture capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final Barcode barcode in barcodes) {
              String barcodeValue = barcode.rawValue!;
              if (barcodeValue.substring(0, 3) == "]C1") {
                barcodeValue = barcodeValue.substring(3);
              }
              widget.onBarcodeScan(barcodeValue);
              cameraController.stop();
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
