import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/components/calculator.dart';
import 'package:n6picking_flutterapp/components/document_line_property_tile.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';
import 'package:provider/provider.dart';

class DocumentLineScreen extends StatefulWidget {
  final DocumentLine documentLine;
  const DocumentLineScreen({required this.documentLine});

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

    final TaskOperation taskOperation = pickingTask.changeDocumentLineQuantity(
      widget.documentLine,
      calculatedValue,
    );

    setState(() {});
    return taskOperation;
  }

  void exit() {
    Navigator.pop(context);
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
              IconButton(
                onPressed: () async {
                  setState(() => showSpinner = true);
                  final TaskOperation taskOperation = await changeQuantity();
                  setState(() => showSpinner = false);
                  if (taskOperation.success) {
                    exit();
                  }
                },
                icon: const FaIcon(
                  FontAwesomeIcons.check,
                  color: kPrimaryColorLight,
                  size: 30.0,
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
                                : '${Helper.removeDecimalZeroFormat(widget.documentLine.quantity + widget.documentLine.quantityPicked)} / ${Helper.removeDecimalZeroFormat(
                                    widget.documentLine.quantityToPick,
                                  )}',
                          ),
                          if (widget.documentLine.product.isBatchTracked)
                            DocumentLinePropertyTile(
                              title: 'Lote',
                              value: widget.documentLine.batch != null
                                  ? widget.documentLine.batch!.batchNumber
                                  : '(sem lote)',
                            ),
                          if (widget.documentLine.product.isBatchTracked)
                            DocumentLinePropertyTile(
                              title: 'Validade',
                              value: widget.documentLine.batch != null
                                  ? DateFormat('dd/MM/yyyy').format(
                                      widget.documentLine.batch!.expirationDate,
                                    )
                                  : '(sem validade)',
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
