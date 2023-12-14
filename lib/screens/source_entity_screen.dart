import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/source_entity_tile.dart';
import 'package:n6picking_flutterapp/models/entity_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:provider/provider.dart';

class SourceEntityScreen extends StatefulWidget {
  static const String id = 'source_entity_screen';

  @override
  _SourceEntityScreenState createState() => _SourceEntityScreenState();
}

class _SourceEntityScreenState extends State<SourceEntityScreen> {
  bool firstSetup = true;
  List<Widget> entityTiles = [];
  Column entityTilesList = const Column();
  late Future listBuild;
  List<Entity> sourceEntityList = [];
  List<Entity> filteredEntityList = [];
  final TextEditingController _entitySearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  void dispose() {
    _entitySearchController.dispose();
    super.dispose();
  }

  Future<void> setup() async {
    listBuild = getFilteredList();
  }

  Future<bool> getFilteredList() async {
    entityTiles.clear();

    if (firstSetup) {
      final pickingTask = Provider.of<PickingTask>(context, listen: false);
      final EntityType entityType =
          pickingTask.destinationDocumentType.entityType;
      sourceEntityList = await EntityApi.getByType(entityType);
    }

    filteredEntityList = await Helper.getEntitySuggestions(
      sourceEntityList,
      _entitySearchController.text,
    );

    for (final Entity entity in filteredEntityList) {
      entityTiles.add(
        SourceEntityTile(
          entity: entity,
        ),
      );
    }

    entityTilesList = Column(children: entityTiles);

    setState(() {
      firstSetup = false;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final pickingTask = Provider.of<PickingTask>(context, listen: false);
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: kGreyBackground,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: kPrimaryColor,
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
                'Selecionar ${pickingTask.destinationDocumentType.entityType.name}',
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      color: kPrimaryColorLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          elevation: 10,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: TextField(
                onSubmitted: (value) {
                  getFilteredList();
                },
                onTapOutside: (value) {
                  getFilteredList();
                },
                cursorColor: kPrimaryColorDark,
                textInputAction: TextInputAction.search,
                decoration: kSearchFieldInputDecoration,
                controller: _entitySearchController,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: FutureBuilder(
                future: listBuild,
                builder: (context, snapshot) {
                  List<Widget> noSnapshotWidgets;
                  if (snapshot.hasData) {
                    if (entityTilesList.children.isEmpty &&
                        _entitySearchController.text.isNotEmpty) {
                      noSnapshotWidgets = [
                        Icon(
                          Icons.error_outline,
                          color: kPrimaryColor.withOpacity(0.6),
                          size: 50,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        const Text(
                          'Não encontrei nenhum resultado',
                          textAlign: TextAlign.center,
                        ),
                      ];
                    } else if (_entitySearchController.text.isEmpty) {
                      noSnapshotWidgets = [
                        Icon(
                          Icons.search,
                          color: kPrimaryColor.withOpacity(0.6),
                          size: 50,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Text(
                          'Pesquise por um ${pickingTask.destinationDocumentType.entityType.name}',
                          textAlign: TextAlign.center,
                        ),
                      ];
                    } else {
                      return SingleChildScrollView(child: entityTilesList);
                    }
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
                    noSnapshotWidgets = const [
                      Text(
                        'A carregar a lista...',
                        textAlign: TextAlign.center,
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
    );
  }
}
