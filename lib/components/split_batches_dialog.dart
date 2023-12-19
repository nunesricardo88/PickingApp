import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';

class SplitBatchesDialog extends StatefulWidget {
  final DocumentLine documentLine;

  const SplitBatchesDialog({required this.documentLine});

  @override
  _SplitBatchesDialogState createState() => _SplitBatchesDialogState();
}

class _SplitBatchesDialogState extends State<SplitBatchesDialog> {
  TextEditingController molhosController = TextEditingController();
  TextEditingController barrasController = TextEditingController();
  TextEditingController compController = TextEditingController();
  late bool _isValid;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    molhosController.dispose();
    barrasController.dispose();
    compController.dispose();
    super.dispose();
  }

  Future<TaskOperation> submit() async {
    final int molhos = int.tryParse(molhosController.text) ?? 0;
    final int barras = int.tryParse(barrasController.text) ?? 0;
    final int comp = int.tryParse(compController.text) ?? 0;

    if (molhos == 0 || barras == 0 || comp == 0) {
      return TaskOperation(
        success: false,
        errorCode: ErrorCode.quantityBelowZero,
        message: 'Preencha todos os campos!',
      );
    }

    return TaskOperation(
      success: true,
      errorCode: ErrorCode.none,
      message: '',
    );
  }

  void exit() {
    final double molhos = double.tryParse(molhosController.text) ?? 0;
    final double barras = double.tryParse(barrasController.text) ?? 0;
    final double comp = double.tryParse(compController.text) ?? 0;
    final List<double> batchData = [
      molhos,
      barras,
      comp,
    ];
    Navigator.pop(context, batchData);
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
          TextField(
            autofocus: molhosController.text.isEmpty &&
                !widget.documentLine.product.isBatchTracked,
            onTap: () {
              molhosController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: molhosController.text.length,
              );
            },
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kPrimaryColor,
                  fontSize: 15.0,
                ),
            controller: molhosController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Nº de Molhos',
              labelStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontSize: 15.0,
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            autofocus: barrasController.text.isEmpty &&
                !widget.documentLine.product.isBatchTracked,
            onTap: () {
              barrasController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: barrasController.text.length,
              );
            },
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kPrimaryColor,
                  fontSize: 15.0,
                ),
            controller: barrasController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Nº de Barras',
              labelStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontSize: 15.0,
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          TextField(
            autofocus: compController.text.isEmpty &&
                !widget.documentLine.product.isBatchTracked,
            onTap: () {
              compController.selection = TextSelection(
                baseOffset: 0,
                extentOffset: compController.text.length,
              );
            },
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kPrimaryColor,
                  fontSize: 15.0,
                ),
            controller: compController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Comprimento das Barras',
              labelStyle: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontSize: 15.0,
                  ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
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
