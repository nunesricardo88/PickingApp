import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/components/document_line_tile.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:provider/provider.dart';

class SingleDocumentLineTile extends DocumentLineTile {
  final DocumentLine documentLine;
  final Location? location;
  final Function(
    DocumentLine,
    Location? location,
  ) callDocumentLineScreen;

  const SingleDocumentLineTile({
    required this.documentLine,
    this.location,
    required this.callDocumentLineScreen,
  });

  @override
  _SingleDocumentLineTileState createState() => _SingleDocumentLineTileState();
}

class _SingleDocumentLineTileState
    extends DocumentLineTileState<SingleDocumentLineTile> {
  @override
  void setupData() {
    final PickingTask pickingTask =
        Provider.of<PickingTask>(context, listen: false);

    //Quantities
    DocumentLine? sourceDocumentLine;
    double quantityPicked = 0.0;
    if (widget.documentLine.linkedLineErpId != null &&
        widget.documentLine.linkedLineErpId!.trim().isNotEmpty) {
      // Get SourceDocumentLine
      for (final Document sourceDocument in pickingTask.sourceDocuments) {
        for (final DocumentLine documentLine in sourceDocument.lines) {
          if (documentLine.erpId!.trim() ==
              widget.documentLine.linkedLineErpId!.trim()) {
            sourceDocumentLine = documentLine;
            quantityPicked = documentLine.quantityPicked;
            break;
          }
        }
      }

      if (sourceDocumentLine != null) {
        final double totalQuantity = sourceDocumentLine.totalQuantity;
        final double quantityToPick = sourceDocumentLine.quantityToPick;

        //Get quantityPicked from all documentLines with the same linkedLineErpId
        for (final DocumentLine documentLine in pickingTask.document!.lines) {
          if (documentLine.linkedLineErpId != null &&
              documentLine.linkedLineErpId!.trim().isNotEmpty &&
              documentLine.linkedLineErpId!.trim() ==
                  widget.documentLine.linkedLineErpId!.trim()) {
            quantityPicked += documentLine.quantity;
          }
        }

        //Update Quantities
        widget.documentLine.quantityPicked = quantityPicked;
        widget.documentLine.totalQuantity = totalQuantity;
        widget.documentLine.quantityToPick = quantityToPick;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DocumentLineTileCard(
      designation: widget.documentLine.designation,
      reference: widget.documentLine.product.reference,
      originLocation: widget.documentLine.originLocation,
      quantity: widget.documentLine.quantity,
      unit: widget.documentLine.product.unit,
      haveLinkedLineErpId: widget.documentLine.linkedLineErpId != null &&
          widget.documentLine.linkedLineErpId!.trim().isNotEmpty,
      quantityPicked: widget.documentLine.quantityPicked,
      totalQuantity: widget.documentLine.totalQuantity,
      product: widget.documentLine.product,
      batch: widget.documentLine.batch,
      backgroundColor: getTileBackgroundColor(
        widget.documentLine.quantity,
        widget.documentLine.quantityPicked,
        widget.documentLine.totalQuantity,
        widget.documentLine.linkedLineErpId != null &&
            widget.documentLine.linkedLineErpId!.trim().isNotEmpty,
      ),
      onPressed: () {
        widget.callDocumentLineScreen(
          widget.documentLine,
          widget.location,
        );
      },
    );
  }
}
