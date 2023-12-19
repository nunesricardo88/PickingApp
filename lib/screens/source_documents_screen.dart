// ignore_for_file: avoid_dynamic_calls, use_build_context_synchronously

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/source_document_tile.dart';
import 'package:n6picking_flutterapp/models/document_model.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:provider/provider.dart';

class SourceDocumentsScreen extends StatefulWidget {
  static const String id = 'source_documents_screen';

  @override
  _SourceDocumentsScreenState createState() => _SourceDocumentsScreenState();
}

class _SourceDocumentsScreenState extends State<SourceDocumentsScreen> {
  List<Document> documentList = [];
  List<Document> selectedDocuments = [];
  bool haveDocumentsSelected = false;
  List<Widget> documentTiles = [];
  Column documentTilesList = const Column();
  late Future listBuild;

  @override
  void initState() {
    super.initState();
    getDocumentsList();
  }

  Future<void> getDocumentsList() async {
    listBuild = getSourceDocumentsList();
  }

  Future<bool> getSourceDocumentsList() async {
    documentTiles.clear();
    final pickingTask = Provider.of<PickingTask>(context, listen: false);

    selectedDocuments = getSelectedSourceDocumentsFromTask();
    documentList = await DocumentApi.getPendingDocuments(pickingTask);

    for (final Document document in documentList) {
      bool isSelected = false;
      for (final Document selectedDocument in selectedDocuments) {
        if (selectedDocument.erpId == document.erpId) {
          isSelected = true;
        }
      }
      documentTiles.add(
        SourceDocumentTile(
          sourceDocument: document,
          isSelected: isSelected,
          onChange: toggleDocumentSelection,
        ),
      );
    }

    documentTilesList = Column(
      children: documentTiles,
    );

    return true;
  }

  bool toggleDocumentSelection(bool select, Document document) {
    if (select) {
      addToSelectedDocuments(document);
    } else {
      removeFromSelectedDocuments(document);
    }
    setState(() {});
    return true;
  }

  List<Document> getSelectedSourceDocumentsFromTask() {
    final pickingTask = Provider.of<PickingTask>(context, listen: false);
    return List.from(pickingTask.sourceDocuments);
  }

  void clearSelectedDocuments() {
    selectedDocuments = [];
  }

  void addToSelectedDocuments(Document document) {
    selectedDocuments.add(document);
  }

  void removeFromSelectedDocuments(Document document) {
    for (final Document selectedDocument in selectedDocuments) {
      if (selectedDocument.erpId == document.erpId) {
        selectedDocuments.remove(selectedDocument);
        break;
      }
    }
  }

  Future<void> setEntityFromSourceDocument(
    PickingTask pickingTask,
    Document sourceDocument,
  ) async {
    final Entity entity = sourceDocument.entity!;
    await pickingTask.setEntity(entity);
  }

  @override
  Widget build(BuildContext context) {
    final PickingTask pickingTask = context.watch<PickingTask>();
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kGreyBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const FaIcon(
                  FontAwesomeIcons.angleLeft,
                  color: kPrimaryColorLight,
                ),
              ),
              const SizedBox(
                width: 15.0,
              ),
              Text(
                'Selecionar documentos',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: kPrimaryColorLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          elevation: 10,
          backgroundColor: kPrimaryColor,
          actions: [
            IconButton(
              onPressed: () async {
                await pickingTask.setSourceDocumentsFromList(selectedDocuments);
                Navigator.pop(context, true);
              },
              icon: const FaIcon(
                FontAwesomeIcons.check,
                color: kPrimaryColorLight,
                size: 20.0,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: listBuild,
                builder: (context, snapshot) {
                  List<Widget> noSnapshotWidgets;
                  if (snapshot.hasData) {
                    return SingleChildScrollView(child: documentTilesList);
                  } else if (snapshot.hasError &&
                      snapshot.connectionState != ConnectionState.waiting) {
                    noSnapshotWidgets = [
                      Icon(
                        Icons.error_outline,
                        color: kPrimaryColor.withOpacity(0.6),
                        size: 50,
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ];
                  } else {
                    noSnapshotWidgets = [
                      const Center(
                        child: CircularProgressIndicator(
                          color: kPrimaryColor,
                        ),
                      ),
                    ];
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: noSnapshotWidgets,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Visibility(
              visible: pickingTask.document!.entity != null &&
                  pickingTask.document!.entity!.entityType !=
                      EntityType.interno,
              child: Flushbar(
                title: 'Entidade atribuída',
                message: pickingTask.document!.entity != null
                    ? pickingTask.document!.entity!.name
                    : '(sem atribuição)',
                mainButton: MaterialButton(
                  onPressed: () async {
                    clearSelectedDocuments();
                    await pickingTask.setEntity(null);
                    await getDocumentsList();
                  },
                  child: Text(
                    'Limpar',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Colors.amber,
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
