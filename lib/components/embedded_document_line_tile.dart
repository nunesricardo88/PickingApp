import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/components/document_line_tile.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';

class EmbeddedDocumentLineTile extends DocumentLineTile {
  final DocumentLine documentLine;
  final Location? location;
  final Function(
    DocumentLine,
    Location? location,
  ) callDocumentLineScreen;

  const EmbeddedDocumentLineTile({
    required this.documentLine,
    this.location,
    required this.callDocumentLineScreen,
  });

  @override
  _EmbeddedDocumentLineTileState createState() =>
      _EmbeddedDocumentLineTileState();
}

class _EmbeddedDocumentLineTileState
    extends DocumentLineTileState<EmbeddedDocumentLineTile> {
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
      quantityPicked: 0,
      totalQuantity: 0,
      product: widget.documentLine.product,
      batch: widget.documentLine.batch,
      backgroundColor: getTileBackgroundColor(
        widget.documentLine.quantity,
        0,
        0,
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
