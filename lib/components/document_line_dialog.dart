import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';
import 'package:provider/provider.dart';

class DocumentLineDialog extends StatefulWidget {
  final DocumentLine documentLine;
  final double defaultQuantity;

  const DocumentLineDialog({
    required this.documentLine,
    this.defaultQuantity = 0.0,
  });

  @override
  _DocumentLineDialogState createState() => _DocumentLineDialogState();
}

class _DocumentLineDialogState extends State<DocumentLineDialog> {
  TextEditingController batchController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  late bool _isValid;
  late bool _isQuantityValid;
  late bool _isBatchValid;
  Batch? _batch;
  bool alreadyValidated = false;
  bool setupDone = false;
  bool isExiting = false;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<void> setup() async {
    batchController.text = widget.documentLine.batch?.batchNumber ?? '';
    quantityController.text = widget.documentLine.quantity.toString();
    if (!widget.documentLine.product.isBatchTracked) {
      quantityController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: quantityController.text.length,
      );
    }
    if (widget.defaultQuantity != 0.0) {
      quantityController.text = widget.defaultQuantity.toString();
    }
    await isDataValid();
    setupDone = true;
  }

  Future<void> validate() async {
    await isDataValid();
  }

  Future<void> isDataValid() async {
    setState(() {
      showSpinner = true;
    });
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    Batch? batch;
    bool isBatchValid = true;
    bool isQuantityValid = true;
    bool isValid = true;

    //Check if the batch is not empty
    if (widget.documentLine.product.isBatchTracked) {
      if (batchController.text.trim().isEmpty) {
        isBatchValid = false;
      }
    }

    //Check if the quantity is not empty
    if (quantityController.text.trim().isEmpty ||
        double.parse(quantityController.text) == 0) {
      isQuantityValid = false;
    } else {
      isQuantityValid = true;
    }

    // //Validate Quantity
    // final double quantity = quantityController.text.isNotEmpty
    //     ? double.parse(quantityController.text.trim())
    //     : 0.0;

    //Validade the existence of the batch if the task is outbound or transfer
    if (isBatchValid) {
      if (widget.documentLine.product.isBatchTracked &&
          (pickingTask.stockMovement == StockMovement.outbound ||
              pickingTask.stockMovement == StockMovement.transfer)) {
        batch = await BatchApi.getByReferenceAndBatchNumber(
          widget.documentLine.product.reference,
          batchController.text.trim(),
        );

        if (batch == null) {
          isBatchValid = false;
        } else {
          isBatchValid = true;
        }
      }
    }

    isValid = isBatchValid && isQuantityValid;

    setState(() {
      showSpinner = false;
    });

    if (isExiting) {
      return;
    }
    setState(() {
      _isBatchValid = isBatchValid;
      _isValid = isValid;
      _batch = batch;
      _isQuantityValid = isQuantityValid;
      if (setupDone) {
        alreadyValidated = true;
      }
    });
  }

  Future<TaskOperation> submit() async {
    //Create the batch
    if (widget.documentLine.product.isBatchTracked) {
      if (_batch != null) {
        widget.documentLine.batch = _batch;
      } else {
        final Batch newBatch = Batch(
          id: Guid.newGuid,
          batchNumber: batchController.text.trim(),
          expirationDate: DateTime(1900),
        );
        widget.documentLine.batch = newBatch;
      }
    }

    widget.documentLine.quantity = double.parse(quantityController.text.trim());

    if (_isBatchValid && _isQuantityValid) {
      return TaskOperation(
        success: true,
        errorCode: ErrorCode.none,
        message: '',
      );
    } else {
      return TaskOperation(
        success: false,
        errorCode: ErrorCode.insufficientDataSubmitted,
        message: 'Dados insuficientes',
      );
    }
  }

  void exit() {
    setState(() {
      isExiting = true;
    });
    batchController.dispose();
    quantityController.dispose();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 20.0),
                  if (widget.documentLine.product.isBatchTracked)
                    Column(
                      children: [
                        TextField(
                          autofocus: batchController.text.isEmpty,
                          controller: batchController,
                          decoration: InputDecoration(
                            labelText: 'Lote',
                            labelStyle: Theme.of(context).textTheme.labelMedium,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        if (alreadyValidated && !_isBatchValid)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              batchController.text.isEmpty
                                  ? 'Preencha o lote'
                                  : 'Lote inválido',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                    color: kErrorColor,
                                    fontSize: 12.0,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 20.0),
                  Column(
                    children: [
                      TextField(
                        autofocus: quantityController.text.isEmpty &&
                            !widget.documentLine.product.isBatchTracked,
                        onTap: () {
                          quantityController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: quantityController.text.length,
                          );
                        },
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantidade',
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          suffix: Text(
                            widget.documentLine.product.unit,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ),
                      if (alreadyValidated && !_isQuantityValid)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            quantityController.text.isEmpty ||
                                    double.parse(quantityController.text) == 0
                                ? 'Preencha a quantidade'
                                : 'Quantidade inválida',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  color: kErrorColor,
                                  fontSize: 12.0,
                                ),
                          ),
                        ),
                    ],
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
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: kPrimaryColor.withOpacity(0.8),
                ),
          ),
        ),
        MaterialButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await validate();
            if (!_isValid) {
              return;
            }
            final TaskOperation taskOperation = await submit();
            if (taskOperation.success) {
              exit();
            }
          },
          child: showSpinner
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  ),
                )
              : Text(
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
