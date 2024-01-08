import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class ManualBarcodeBox extends StatefulWidget {
  @override
  _ManualBarcodeBoxState createState() => _ManualBarcodeBoxState();
}

class _ManualBarcodeBoxState extends State<ManualBarcodeBox> {
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: kWhiteBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      actionsPadding: const EdgeInsets.only(
        right: 10.0,
        bottom: 5.0,
      ),
      content: BarcodeKeyboardListener(
        onBarcodeScanned: (barcode) async {
          setState(() {
            myController.text = barcode;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: myController,
              style: Theme.of(context).textTheme.labelSmall,
              decoration: kPickTextFieldsInputDecoration.copyWith(
                hintText: 'Código',
                prefixIcon: const Icon(
                  FontAwesomeIcons.barcode,
                  size: 15.0,
                  color: kPrimaryColorDark,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context, "");
          },
          child: Text(
            'Cancelar',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: kPrimaryColor.withOpacity(0.8),
                ),
          ),
        ),
        MaterialButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.pop(context, myController.text);
          },
          child: Text(
            'Submeter',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: kPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}
