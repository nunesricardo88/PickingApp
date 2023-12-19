import 'package:flutter/material.dart';
import 'package:flutter_guid/flutter_guid.dart';
import 'package:n6picking_flutterapp/models/batch_model.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';
import 'package:provider/provider.dart';

class DocumentLineDialog extends StatefulWidget {
  final DocumentLine documentLine;

  const DocumentLineDialog({required this.documentLine});

  @override
  _DocumentLineDialogState createState() => _DocumentLineDialogState();
}

class _DocumentLineDialogState extends State<DocumentLineDialog> {
  TextEditingController batchController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  late bool _isValid;
  late bool _isBatchValid;

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
    await isDataValid();
  }

  Future<void> isDataValid() async {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

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
        quantityController.text == '0') {
      isQuantityValid = false;
    } else {
      isQuantityValid = true;
    }

    final double quantity = double.parse(quantityController.text.trim());

    //Validade the existence of the batch if the task is outbound or transfer
    if (isBatchValid) {
      if (widget.documentLine.product.isBatchTracked &&
          (pickingTask.stockMovement == StockMovement.outbound ||
              pickingTask.stockMovement == StockMovement.transfer)) {
        final Batch? batch = await BatchApi.getByReferenceAndBatchNumber(
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
      _isBatchValid = isBatchValid;
      _isValid = isValid;
    });
  }

  Future<TaskOperation> submit() async {
    //Create the batch
    if (widget.documentLine.product.isBatchTracked) {
      final Batch batch = Batch(
        id: Guid.newGuid,
        batchNumber: batchController.text.trim(),
        expirationDate: DateTime(1900),
      );
      widget.documentLine.batch = batch;
    }

    widget.documentLine.quantity = double.parse(quantityController.text.trim());

    return TaskOperation(
      success: true,
      errorCode: ErrorCode.none,
      message: '',
    );
  }

  void exit() {
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.documentLine.product.designation,
            style: Theme.of(context).textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20.0),
          if (widget.documentLine.product.isBatchTracked)
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
              onSubmitted: (value) async {
                await isDataValid();
              },
            ),
          const SizedBox(height: 20.0),
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
            onSubmitted: (value) async {
              await isDataValid();
            },
          ),
        ],
      ),
      actions: [
        MaterialButton(
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
          onPressed: () async {
            final TaskOperation taskOperation = await submit();
            if (taskOperation.success) {
              exit();
            } else {
              // ignore: use_build_context_synchronously
              Helper.showMsg(
                'Atenção',
                taskOperation.message,
                context,
              );
            }
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
