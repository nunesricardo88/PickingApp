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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      backgroundColor: kGreyBackground,
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
          onPressed: () {
            Navigator.pop(context, "");
          },
          child: Text(
            'Cancelar',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        MaterialButton(
          onPressed: () {
            Navigator.pop(context, myController.text);
          },
          child: Text(
            'Submeter',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
