import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';

class DocumentLineTile extends StatefulWidget {
  final DocumentLine documentLine;
  const DocumentLineTile({
    required this.documentLine,
  });

  @override
  _DocumentLineTileState createState() => _DocumentLineTileState();
}

class _DocumentLineTileState extends State<DocumentLineTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
      child: MaterialButton(
        padding: EdgeInsets.zero,
        onPressed: () async {
          //Get the picking task screen
        },
        child: Card(
          color: kWhiteBackground,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.documentLine.product.designation,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          widget.documentLine.product.reference,
                        ),
                      ),
                      Visibility(
                        visible: widget.documentLine.batch != null,
                        child: const SizedBox(
                          height: 5.0,
                        ),
                      ),
                      if (widget.documentLine.batch != null)
                        Opacity(
                          opacity: 0.5,
                          child: Text(
                            'Lote: ${widget.documentLine.batch!.batchNumber}',
                          ),
                        ),
                      const SizedBox(
                        height: 5.0,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Helper.removeDecimalZeroFormat(
                            widget.documentLine.quantity,
                          ),
                        ),
                        Visibility(
                          visible: widget.documentLine.linkedLineErpId != null,
                          child: Row(
                            children: [
                              Text(
                                Helper.removeDecimalZeroFormat(
                                  widget.documentLine.quantityPicked,
                                ),
                              ),
                              Text(
                                ' / ${Helper.removeDecimalZeroFormat(widget.documentLine.quantityToPick)}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
