import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:provider/provider.dart';

class SourceDocumentTile extends StatefulWidget {
  final Document sourceDocument;
  const SourceDocumentTile({required this.sourceDocument});

  @override
  _SourceDocumentTileState createState() => _SourceDocumentTileState();
}

class _SourceDocumentTileState extends State<SourceDocumentTile> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> setEntityFromSourceDocument(PickingTask pickingTask) async {
    final Entity entity = widget.sourceDocument.entity!;
    pickingTask.setEntity(entity);
  }

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = context.watch<PickingTask>();
    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          value: Helper.isContainedInSourceDocumentTempList(
            pickingTask,
            widget.sourceDocument,
          ),
          onChanged: (value) async {
            final bool selected = value!;
            if (selected && pickingTask.document!.entity == null) {
              await setEntityFromSourceDocument(pickingTask);
            }
            if (selected) {
              pickingTask.addToSourceDocumentTempList(widget.sourceDocument);
            } else {
              pickingTask
                  .removeFromSourceDocumentTempList(widget.sourceDocument);
            }
            setState(() {});
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
