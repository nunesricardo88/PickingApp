import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/manual_barcode_box.dart';
import 'package:n6picking_flutterapp/screens/camera_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class AppBottomBar extends StatefulWidget {
  const AppBottomBar({
    this.fabLocation = FloatingActionButtonLocation.centerDocked,
    this.shape = const CircularNotchedRectangle(),
    required this.onBarcodeScan,
  });

  final FloatingActionButtonLocation fabLocation;
  final NotchedShape? shape;
  final Future<void> Function(String) onBarcodeScan;
  @override
  _AppBottomBarState createState() => _AppBottomBarState();
}

class _AppBottomBarState extends State<AppBottomBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget getLeftButton() {
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: MenuAnchor(
        style: MenuStyle(
          backgroundColor: MaterialStateColor.resolveWith(
            (states) => kPrimaryColor,
          ),
        ),
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            icon: FaIcon(
              FontAwesomeIcons.bars,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 30.0,
            ),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          );
        },
        menuChildren: [
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.layerGroup,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            child: Text(
              'Inserir molho',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            onPressed: () async {},
          ),
        ],
      ),
    );
  }

  Widget getRightButton() {
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: MenuAnchor(
        style: MenuStyle(
          backgroundColor: MaterialStateColor.resolveWith(
            (states) => kPrimaryColor,
          ),
        ),
        builder:
            (BuildContext context, MenuController controller, Widget? child) {
          return IconButton(
            icon: FaIcon(
              FontAwesomeIcons.qrcode,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 30.0,
            ),
            onPressed: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
          );
        },
        menuChildren: [
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.camera,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            child: Text(
              'Usar câmara',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CameraScreen(onBarcodeScan: widget.onBarcodeScan),
                ),
              );
            },
          ),
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.keyboard,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            child: Text(
              'Código manual',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            onPressed: () async {
              await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return ManualBarcodeBox();
                },
              ).then((barcode) async {
                if (barcode is String) {
                  await widget.onBarcodeScan(barcode);
                }
              });
            },
          ),
          MenuItemButton(
            leadingIcon: FaIcon(
              FontAwesomeIcons.magnifyingGlass,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20.0,
            ),
            child: Text(
              'Procurar artigo',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 60.0,
      shape: widget.shape,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: kPrimaryColor,
      surfaceTintColor: Colors.transparent,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            getLeftButton(),
            getRightButton(),
          ],
        ),
      ),
    );
  }
}
