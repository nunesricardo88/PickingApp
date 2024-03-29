import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/components/calculator.dart';
import 'package:n6picking_flutterapp/components/document_line_dialog.dart';
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
  TextEditingController labelQuantityController = TextEditingController();
  TextEditingController newBarcodeController = TextEditingController();
  bool showSpinner = false;
  double calculatedValue = 0.0;
  bool isExiting = false;

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

    final TaskOperation taskOperation = pickingTask.addToDocumentLineQuantity(
      widget.documentLine,
      calculatedValue - widget.documentLine.quantity,
    );

    if (widget.documentLine.product.isBatchTracked &&
        calculatedValue > 0.0 &&
        widget.documentLine.batch == null) {
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return DocumentLineDialog(
            documentLine: widget.documentLine,
          );
        },
      );
    }

    setState(() {});
    return taskOperation;
  }

  Future<void> submitLabelPrint() async {
    final String value = labelQuantityController.text;
    final int valueInt = value.isEmpty ? 0 : int.parse(value);

    if (valueInt > 0) {
      setState(() {
        showSpinner = true;
      });
      final TaskOperation taskOperation = await printLabel(valueInt);
      setState(() {
        showSpinner = false;
      });
      // ignore: use_build_context_synchronously
      Flushbar(
        titleSize: 0,
        message: taskOperation.message,
        duration: const Duration(seconds: 2),
      ).show(context);
    }
  }

  Future<TaskOperation> printLabel(int quantity) async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    final TaskOperation taskOperation =
        await pickingTask.printLabel(widget.documentLine, quantity);

    return taskOperation;
  }

  void exit(List<double>? value) {
    isExiting = true;
    labelQuantityController.dispose();
    newBarcodeController.dispose();
    if (value != null) {
      Navigator.pop(context, value);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> submitNewBarcode() async {
    final String value = newBarcodeController.text;

    if (value.isNotEmpty) {
      setState(() {
        showSpinner = true;
      });
      final TaskOperation taskOperation = await postNewBarcode(value);
      setState(() {
        showSpinner = false;
      });
      // ignore: use_build_context_synchronously
      Flushbar(
        titleSize: 0,
        message: taskOperation.message,
        duration: const Duration(seconds: 2),
      ).show(context);
    }
  }

  Future<TaskOperation> postNewBarcode(String barcode) async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    final TaskOperation taskOperation =
        await pickingTask.postNewBarcode(widget.documentLine, barcode);

    return taskOperation;
  }

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
            backgroundColor: kPrimaryColor,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.angleLeft,
                  color: kPrimaryColorLight,
                  size: 30.0,
                ),
              ),
            ),
            title: Text(
              'Editar linha',
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: kPrimaryColorLight,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            titleSpacing: 0.0,
            elevation: 10,
            actions: [
              if (widget.documentLine.product.usaMolho &&
                  widget.documentLine.product.isBatchTracked)
                IconButton(
                  padding: EdgeInsets.zero,
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
                  icon: const FaIcon(
                    FontAwesomeIcons.layerGroup,
                    color: kPrimaryColorLight,
                  ),
                ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        surfaceTintColor: kWhiteBackground,
                        actionsPadding: const EdgeInsets.only(
                          right: 10.0,
                          bottom: 5.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        contentPadding: const EdgeInsets.only(
                          top: 20.0,
                          left: 20.0,
                          right: 20.0,
                          bottom: 5.0,
                        ),
                        content: SingleChildScrollView(
                          child: isExiting
                              ? const SizedBox(height: 100.0)
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.documentLine.designation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 20.0),
                                    TextField(
                                      autofocus: true,
                                      onTap: () {
                                        newBarcodeController.selection =
                                            TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                              newBarcodeController.text.length,
                                        );
                                      },
                                      controller: newBarcodeController,
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        labelText: 'Novo código de barras',
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
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
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancelar',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: kPrimaryColor.withOpacity(0.8),
                                  ),
                            ),
                          ),
                          MaterialButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              submitNewBarcode();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Submeter',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.barcode,
                  color: kPrimaryColorLight,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  labelQuantityController.text = '1';
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        surfaceTintColor: kWhiteBackground,
                        actionsPadding: const EdgeInsets.only(
                          right: 10.0,
                          bottom: 5.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        contentPadding: const EdgeInsets.only(
                          top: 20.0,
                          left: 20.0,
                          right: 20.0,
                          bottom: 5.0,
                        ),
                        content: SingleChildScrollView(
                          child: isExiting
                              ? const SizedBox(height: 100.0)
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.documentLine.designation,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 20.0),
                                    TextField(
                                      onTap: () {
                                        labelQuantityController.selection =
                                            TextSelection(
                                          baseOffset: 0,
                                          extentOffset: labelQuantityController
                                              .text.length,
                                        );
                                      },
                                      controller: labelQuantityController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Nº de etiquetas a imprimir',
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        suffix: Text(
                                          widget.documentLine.product.unit,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium,
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
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Cancelar',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: kPrimaryColor.withOpacity(0.8),
                                  ),
                            ),
                          ),
                          MaterialButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              submitLabelPrint();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Submeter',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const FaIcon(
                  FontAwesomeIcons.print,
                  color: kPrimaryColorLight,
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
                            value: widget.documentLine.designation,
                          ),
                          DocumentLinePropertyTile(
                            title: 'Quantidade',
                            value: widget.documentLine.linkedLineErpId ==
                                        null &&
                                    widget.documentLine.quantityToPick > 0
                                ? Helper.removeDecimalZeroFormat(
                                    widget.documentLine.quantity,
                                  )
                                : '${Helper.removeDecimalZeroFormat(widget.documentLine.quantityPicked)} ${widget.documentLine.quantityToPick > 0 ? ' / ${Helper.removeDecimalZeroFormat(widget.documentLine.totalQuantity)}' : ''}',
                          ),
                          if (widget.documentLine.product.isBatchTracked)
                            GestureDetector(
                              onTap: () async {
                                await showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DocumentLineDialog(
                                      documentLine: widget.documentLine,
                                    );
                                  },
                                ).then(
                                  (value) => setState(() {
                                    setup();
                                  }),
                                );
                              },
                              child: DocumentLinePropertyTile(
                                title: 'Lote',
                                value: widget.documentLine.batch != null
                                    ? widget.documentLine.batch!.batchNumber
                                    : '(sem lote)',
                              ),
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
