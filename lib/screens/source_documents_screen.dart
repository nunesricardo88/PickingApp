// ignore_for_file: avoid_dynamic_calls, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/loading_display.dart';
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
  List<Document> filteredDocumentList = [];
  List<Document> selectedDocuments = [];
  Entity? selectedEntity;
  List<Widget> documentTiles = [];
  Column documentTilesList = const Column();
  late Future listBuild;
  bool showSpinner = false;
  String spinnerMessage = 'Por favor, aguarde';

  @override
  void initState() {
    super.initState();
    setup();
  }

  void showLoadingDisplay(String message) {
    setState(() {
      showSpinner = true;
      spinnerMessage = message;
    });
  }

  void hideLoadingDisplay() {
    setState(() {
      showSpinner = false;
    });
  }

  Future<void> setup() async {
    final pickingTask = Provider.of<PickingTask>(context, listen: false);
    selectedEntity = pickingTask.document!.entity;
    await getDocumentsList();
  }

  Future<void> getDocumentsList() async {
    selectedDocuments = getSelectedSourceDocumentsFromTask();
    listBuild = getSourceDocumentsList();
  }

  Future<bool> getSourceDocumentsList() async {
    final pickingTask = Provider.of<PickingTask>(context, listen: false);

    documentList = await DocumentApi.getPendingDocuments(pickingTask);
    await filterSourceDocumentsByEntity();

    return true;
  }

  Future<bool> toggleDocumentSelection(bool select, Document document) async {
    if (select) {
      await addToSelectedDocuments(document);
    } else {
      await removeFromSelectedDocuments(document);
    }

    Entity? newSelectedEntity;
    if (selectedDocuments.isNotEmpty) {
      newSelectedEntity = selectedDocuments.first.entity;
    } else {
      newSelectedEntity = null;
    }

    setState(() {
      selectedEntity = newSelectedEntity;
    });

    await filterSourceDocumentsByEntity();

    return true;
  }

  Future<void> filterSourceDocumentsByEntity() async {
    filteredDocumentList = documentList.where((document) {
      if (selectedEntity != null) {
        return document.entity!.erpId.trim() == selectedEntity!.erpId.trim();
      } else {
        return true;
      }
    }).toList();

    documentTiles.clear();
    for (final Document document in filteredDocumentList) {
      bool isSelected = false;
      for (final Document selectedDocument in selectedDocuments) {
        if (selectedDocument.erpId!.trim() == document.erpId!.trim()) {
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
  }

  List<Document> getSelectedSourceDocumentsFromTask() {
    final pickingTask = Provider.of<PickingTask>(context, listen: false);
    return List.from(pickingTask.sourceDocuments);
  }

  void clearSelectedDocuments() {
    selectedDocuments = [];
  }

  Future<void> addToSelectedDocuments(Document document) async {
    final bool alreadySelected = selectedDocuments.any(
      (element) => element.erpId!.trim() == document.erpId!.trim(),
    );

    if (!alreadySelected) {
      selectedDocuments.add(document);
    }
  }

  Future<void> removeFromSelectedDocuments(Document document) async {
    selectedDocuments.removeWhere(
      (element) => element.erpId!.trim() == document.erpId!.trim(),
    );
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
          backgroundColor: kPrimaryColor,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.angleLeft,
                color: kPrimaryColorLight,
                size: 30.0,
              ),
            ),
          ),
          title: Text(
            'Selecionar documentos',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: kPrimaryColorLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
          titleSpacing: 0.0,
          elevation: 10,
          actions: [
            IconButton(
              onPressed: () async {
                showLoadingDisplay('A carregar as linhas');

                //Set Entity
                if (selectedDocuments.isEmpty) {
                  await pickingTask.setEntity(null);
                } else {
                  await setEntityFromSourceDocument(
                    pickingTask,
                    selectedDocuments.first,
                  );
                }

                //Set Source Documents
                await pickingTask.setSourceDocumentsFromList(selectedDocuments);

                hideLoadingDisplay();
                Navigator.pop(context, true);
              },
              icon: const FaIcon(
                FontAwesomeIcons.check,
                color: kPrimaryColorLight,
                size: 30.0,
              ),
            ),
          ],
        ),
        body: LoadingDisplay(
          isLoading: showSpinner,
          loadingText: spinnerMessage,
          child: Column(
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
            ],
          ),
        ),
      ),
    );
  }
}
