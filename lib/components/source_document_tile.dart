import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CheckboxListTile(
          dense: true,
          controlAffinity: ListTileControlAffinity.leading,
          value: widget.isSelected,
          onChanged: (value) async {
            final bool selected = value!;
            // ignore: avoid_dynamic_calls
            await widget.onChange(selected, widget.sourceDocument);
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
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.sourceDocument.documentType.number != 999)
                Text(
                  widget.sourceDocument.entity!.name,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              Text(
                widget.sourceDocument.documentType.number == 999
                    ? widget.sourceDocument.name!
                    : '# ${widget.sourceDocument.number}',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
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
