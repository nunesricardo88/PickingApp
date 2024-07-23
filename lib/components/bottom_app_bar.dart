// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    this.shape = const CircularNotchedRectangle(),
  });

  final NotchedShape? shape;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 60.0,
      shape: shape,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      color: kPrimaryColor,
      surfaceTintColor: Colors.transparent,
      child: IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LeftBottomButton(),
            RightBottomButton(),
          ],
        ),
      ),
    );
  }
}

class RightBottomButton extends StatelessWidget {
  const RightBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: IconButton(
        icon: const FaIcon(
          FontAwesomeIcons.qrcode,
        ),
        onPressed: () {
          Scaffold.of(context).openEndDrawer();
        },
      ),
    );
  }
}

class LeftBottomButton extends StatelessWidget {
  const LeftBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: IconButton(
        icon: const FaIcon(
          FontAwesomeIcons.bars,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
    );
  }
}
