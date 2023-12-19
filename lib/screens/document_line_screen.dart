import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/components/calculator.dart';
import 'package:n6picking_flutterapp/components/document_line_property_tile.dart';
import 'package:n6picking_flutterapp/components/split_batches_dialog.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';
import 'package:provider/provider.dart';

class DocumentLineScreen extends StatefulWidget {
  final DocumentLine documentLine;
  final Location? location;
  const DocumentLineScreen({
    required this.documentLine,
    this.location,
  });

  @override
  _DocumentLineScreenState createState() => _DocumentLineScreenState();
}

class _DocumentLineScreenState extends State<DocumentLineScreen> {
  bool showSpinner = false;
  double calculatedValue = 0.0;

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() {
    setState(() {
      calculatedValue = widget.documentLine.quantity;
    });
  }

  Future<TaskOperation> changeQuantity() async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    if (widget.location != null &&
        widget.documentLine.destinationLocation == null) {
      widget.documentLine.destinationLocation = widget.location;
    }

    final TaskOperation taskOperation = pickingTask.changeDocumentLineQuantity(
      widget.documentLine,
      calculatedValue - widget.documentLine.quantity,
    );

    setState(() {});
    return taskOperation;
  }

  void exit(List<double>? value) {
    if (value != null) {
      Navigator.pop(context, value);
    } else {
      Navigator.pop(context);
    }
  }

  //TODO - Save a new barcode

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: LoadingOverlay(
        isLoading: showSpinner,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: kGreyBackground,
          appBar: AppBar(
            automaticallyImplyLeading: false,
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
                  'Editar linha',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: kPrimaryColorLight,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            elevation: 10,
            backgroundColor: kPrimaryColor,
            actions: [
              if (widget.documentLine.product.usaMolho &&
                  widget.documentLine.product.isBatchTracked)
                MaterialButton(
                  onPressed: () async {
                    await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context) {
                        return SplitBatchesDialog(
                          documentLine: widget.documentLine,
                        );
                      },
                    ).then(
                      (value) {
                        exit(value as List<double>?);
                      },
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        'Dividir lotes',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: kWhiteBackground,
                            ),
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      const FaIcon(
                        FontAwesomeIcons.layerGroup,
                        color: kPrimaryColorLight,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: kWhiteBackground,
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 6.0,
                      ),
                      child: Column(
                        children: [
                          DocumentLinePropertyTile(
                            title: 'Referência',
                            value: widget.documentLine.product.reference,
                          ),
                          DocumentLinePropertyTile(
                            title: 'Designação',
                            value: widget.documentLine.product.designation,
                          ),
                          DocumentLinePropertyTile(
                            title: 'Quantidade',
                            value: widget.documentLine.linkedLineErpId ==
                                        null &&
                                    widget.documentLine.quantityToPick > 0
                                ? Helper.removeDecimalZeroFormat(
                                    widget.documentLine.quantity,
                                  )
                                : '${Helper.removeDecimalZeroFormat(widget.documentLine.quantity)} ${widget.documentLine.quantityToPick > 0 ? ' / ${Helper.removeDecimalZeroFormat(widget.documentLine.quantityToPick)}' : ''}',
                          ),
                          if (widget.documentLine.product.isBatchTracked)
                            DocumentLinePropertyTile(
                              title: 'Lote',
                              value: widget.documentLine.batch != null
                                  ? widget.documentLine.batch!.batchNumber
                                  : '(sem lote)',
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  Flexible(
                    child: Material(
                      color: kWhiteBackground,
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Calculator(
                              key: ValueKey<double>(calculatedValue),
                              calculatedValue: calculatedValue,
                              callBackValue: (double value) {
                                setState(() {
                                  calculatedValue = value;
                                });
                              },
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryColor,
                                  surfaceTintColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () async {
                                  final TaskOperation taskOperation =
                                      await changeQuantity();

                                  if (taskOperation.success) {
                                    exit(null);
                                  }
                                },
                                child: Text(
                                  'Submeter',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                        color: kWhiteBackground,
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
