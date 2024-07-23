import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/models/misc_data_model.dart';
import 'package:n6picking_flutterapp/screens/misc_data_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class DrawerLeftMenu extends StatelessWidget {
  const DrawerLeftMenu({
    super.key,
    this.lineGroupType = LineGroupType.none,
    required this.onGroupByNone,
    required this.onGroupByProductRef,
    required this.onGroupByProductRefAndBatch,
    required this.onGroupByContainerBarcode,
    required this.onMiscDataChanged,
    required this.miscDataList,
  });

  final Future<void> Function(List<MiscData>) onMiscDataChanged;
  final List<MiscData> miscDataList;
  final LineGroupType lineGroupType;
  final Future<void> Function() onGroupByNone;
  final Future<void> Function() onGroupByProductRef;
  final Future<void> Function() onGroupByProductRefAndBatch;
  final Future<void> Function() onGroupByContainerBarcode;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: kGreyBackground,
            ),
            child: Text(
              'Opções',
              style: TextStyle(fontSize: 24),
            ),
          ),
          if (miscDataList.isNotEmpty)
            ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.penToSquare,
              ),
              title: const Text(
                'Outros dados',
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MiscDataScreen(
                      miscDataList: miscDataList,
                    ),
                  ),
                ).then(
                  (value) {
                    if (value is List<MiscData>) {
                      onMiscDataChanged(value);
                    }
                  },
                );
              },
            ),
          ExpansionTile(
            leading: const FaIcon(
              FontAwesomeIcons.layerGroup,
            ),
            title: const Text('Agrupar'),
            children: <Widget>[
              ListTile(
                title: Text(
                  'Agrupar por referência',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: lineGroupType == LineGroupType.product
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                ),
                tileColor: lineGroupType == LineGroupType.product
                    ? kPrimaryColor
                    : null,
                onTap: onGroupByProductRef,
              ),
              ListTile(
                title: Text(
                  'Agrupar por referência e lote',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: lineGroupType == LineGroupType.productBatch
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                ),
                tileColor: lineGroupType == LineGroupType.productBatch
                    ? kPrimaryColor
                    : null,
                onTap: onGroupByProductRefAndBatch,
              ),
              ListTile(
                title: Text(
                  'Agrupar por container',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: lineGroupType == LineGroupType.container
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                ),
                tileColor: lineGroupType == LineGroupType.container
                    ? kPrimaryColor
                    : null,
                onTap: onGroupByContainerBarcode,
              ),
              ListTile(
                title: Text(
                  'Desagrupar',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: lineGroupType == LineGroupType.none
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                ),
                tileColor:
                    lineGroupType == LineGroupType.none ? kPrimaryColor : null,
                onTap: onGroupByNone,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
