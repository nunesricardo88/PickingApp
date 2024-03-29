// ignore_for_file: avoid_dynamic_calls, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/screens/camera_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';

class ConfigureEndpointScreen extends StatefulWidget {
  static const String id = 'configure_endpoint_screen';

  @override
  _ConfigureEndpointScreenState createState() =>
      _ConfigureEndpointScreenState();
}

class _ConfigureEndpointScreenState extends State<ConfigureEndpointScreen> {
  bool firstSetup = true;
  bool isCheckingServerConnection = false;

  late bool isOnline;

  @override
  void initState() {
    super.initState();
    getServerConnection();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getServerConnection() async {
    setState(() => isCheckingServerConnection = true);

    final bool _isOnline = await System.instance.isConnectedToServer();
    if (_isOnline) {
      System.instance.apiVersion = await System.instance.getApiVersion();
    }

    setState(() {
      firstSetup = false;
      isOnline = _isOnline;
      isCheckingServerConnection = false;
    });
  }

  Future<bool> getScannerQRConnection(String scannedString) async {
    final scannedJson = jsonDecode(scannedString);

    final bool hasUrl = scannedJson.containsKey("url") as bool;
    final bool hasPort = scannedJson.containsKey("port") as bool;

    if (hasUrl && hasPort) {
      await System.instance.setApiConnection(
        scannedJson["url"] as String,
        scannedJson["port"] as String,
      );

      await getServerConnection();

      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BarcodeKeyboardListener(
      onBarcodeScanned: (barcode) async {
        await getScannerQRConnection(barcode);
      },
      child: Container(
        decoration: BoxDecoration(
          color: kPrimaryColorLight,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: kPrimaryColorDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: SizedBox(
                height: 45.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Ligação ao servidor',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: kPrimaryColorLight,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    'Estado:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    isCheckingServerConnection || firstSetup
                        ? 'A verificar'
                        : isOnline
                            ? 'Online'
                            : 'Offline',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isCheckingServerConnection || firstSetup
                              ? kPrimaryColorDark
                              : isOnline
                                  ? kAccentColor
                                  : kErrorColor,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CameraScreen(onBarcodeScan: getScannerQRConnection),
                      ),
                    );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.camera,
                    color: kPrimaryColor,
                    size: 15.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
