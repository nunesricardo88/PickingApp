import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';

class SourceDocumentTile extends StatefulWidget {
  final Document sourceDocument;
  final bool isSelected;
  final Function onChange;
  const SourceDocumentTile({
    required this.sourceDocument,
    required this.isSelected,
    required this.onChange,
  });

  @override
  _SourceDocumentTileState createState() => _SourceDocumentTileState();
}

class _SourceDocumentTileState extends State<SourceDocumentTile> {
  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    setup();
  }

  void setup() {
    _isSelected = widget.isSelected;
  }

  Future<void> setEntityFromSourceDocument(PickingTask pickingTask) async {
    final Entity entity = widget.sourceDocument.entity!;
    pickingTask.setEntity(entity);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          value: _isSelected,
          onChanged: (value) async {
            final bool selected = value!;
            // ignore: avoid_dynamic_calls
            widget.onChange(selected, widget.sourceDocument);
            setState(() {
              _isSelected = selected;
            });
          },
          contentPadding: const EdgeInsets.only(
            left: 10.0,
            right: 20.0,
          ),
          title: Text(
            widget.sourceDocument.documentType.name,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          subtitle: Text(
            '# ${widget.sourceDocument.number}',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const Divider(
          height: 1.0,
          thickness: 1.0,
        ),
      ],
    );
  }
}
