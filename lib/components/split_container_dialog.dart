import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/task_operation.dart';

class SplitContainerDialog extends StatefulWidget {
  final DocumentLine documentLine;

  const SplitContainerDialog({required this.documentLine});

  @override
  _SplitContainerDialogState createState() => _SplitContainerDialogState();
}

class _SplitContainerDialogState extends State<SplitContainerDialog> {
  TextEditingController countContainers = TextEditingController();
  TextEditingController countProducts = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    countContainers.dispose();
    countProducts.dispose();
    super.dispose();
  }

  Future<TaskOperation> submit() async {
    final int containerCount = int.tryParse(countContainers.text) ?? 0;
    final double productCount = double.tryParse(countProducts.text) ?? 0;

    if (containerCount == 0 || productCount == 0) {
      return TaskOperation(
        success: false,
        errorCode: ErrorCode.quantityBelowZero,
        message: 'Preencha todos os campos!',
      );
    }

    final double totalProducts = containerCount * productCount;
    if (totalProducts > widget.documentLine.quantity) {
      return TaskOperation(
        success: false,
        errorCode: ErrorCode.quantityAboveMax,
        message: 'Não pode dividir em mais artigos do que o total!',
      );
    }

    return TaskOperation(
      success: true,
      errorCode: ErrorCode.none,
      message: '',
    );
  }

  void exit() {
    final double containerCount = double.tryParse(countContainers.text) ?? 0;
    final double productCount = double.tryParse(countProducts.text) ?? 0;
    final List<double> containerData = [
      containerCount,
      productCount,
    ];
    Navigator.pop(context, containerData);
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
            widget.documentLine.designation,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 20.0),
          TextField(
            autofocus: true,
            onTap: () {
              countContainers.selection = TextSelection(
                baseOffset: 0,
                extentOffset: countContainers.text.length,
              );
            },
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kPrimaryColor,
                  fontSize: 15.0,
                ),
            controller: countContainers,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Containers',
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
            onTap: () {
              countProducts.selection = TextSelection(
                baseOffset: 0,
                extentOffset: countProducts.text.length,
              );
            },
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: kPrimaryColor,
                  fontSize: 15.0,
                ),
            controller: countProducts,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Artigos por container',
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
