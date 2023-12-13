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

  Color getTileBackgroundColor() {
    return kWhiteBackground;
  }

  BorderSide getTileBorder() {
    return BorderSide(
      color: kPrimaryColor.withOpacity(0.1),
      width: 1.5,
    );
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
          color: getTileBackgroundColor(),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: getTileBorder(),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        widget.documentLine.product.reference,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (widget.documentLine.batch != null)
                        const SizedBox(
                          height: 5.0,
                        ),
                      if (widget.documentLine.batch != null)
                        Opacity(
                          opacity: 0.5,
                          child: Text(
                            'Lote: ${widget.documentLine.batch?.batchNumber}',
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
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
                          style:
                              Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                        if (widget.documentLine.linkedLineErpId != null)
                          Row(
                            children: [
                              Text(
                                Helper.removeDecimalZeroFormat(
                                  widget.documentLine.quantityPicked,
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                ' / ${Helper.removeDecimalZeroFormat(widget.documentLine.quantityToPick)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
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
