import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/components/single_document_line_tile.dart';
import 'package:n6picking_flutterapp/models/document_line_model.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class ContainerLines extends StatefulWidget {
  const ContainerLines({
    super.key,
    required this.documentLines,
    this.location,
    required this.callDocumentLineScreen,
  });

  final List<DocumentLine> documentLines;
  final Location? location;
  final Function(
    DocumentLine,
    Location? location,
  ) callDocumentLineScreen;

  @override
  State<ContainerLines> createState() => _ContainerLinesState();
}

class _ContainerLinesState extends State<ContainerLines> {
  //FutureBuilder DocumentLines
  List<Widget> documentLineTiles = [];
  Column documentTilesList = const Column();

  @override
  void initState() {
    super.initState();
    setupData();
  }

  @override
  void didUpdateWidget(covariant ContainerLines oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.documentLines != oldWidget.documentLines) {
      setupData();
    }
  }

  Future<void> setupData() async {
    documentLineTiles.clear();
    documentLineTiles.add(
      Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.documentLines.first.container?.barcode ?? 'Sem container',
            ),
          ),
        ],
      ),
    );

    for (final DocumentLine line in widget.documentLines) {
      documentLineTiles.add(
        SingleDocumentLineTile(
          documentLine: line,
          location: widget.location,
          callDocumentLineScreen: widget.callDocumentLineScreen,
        ),
      );
    }

    documentTilesList = Column(
      children: documentLineTiles,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: kContainerBackground,
      ),
      child: documentTilesList,
    );
  }
}
