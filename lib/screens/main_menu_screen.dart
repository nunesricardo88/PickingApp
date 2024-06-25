import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:n6picking_flutterapp/components/loading_display.dart';
import 'package:n6picking_flutterapp/components/menu_item_card.dart';
import 'package:n6picking_flutterapp/models/location_model.dart';
import 'package:n6picking_flutterapp/models/picking_task_model.dart';
import 'package:n6picking_flutterapp/models/product_model.dart';
import 'package:n6picking_flutterapp/screens/login_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';

class MainMenuScreen extends StatefulWidget {
  static const String id = 'main_menu_screen';

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  List<PickingTask> pickingTasks = [];
  List<Widget> menuItemCards = [];
  Column menuItemCardsList = const Column();
  bool showSpinner = false;
  String spinnerMessage = 'Por favor, aguarde';
  late Future menuBuild;

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<void> setup() async {
    menuBuild = buildMenu();
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

  Future<bool> buildMenu() async {
    showLoadingDisplay('A sincronizar produtos');
    await ProductApi.instance.initialize();
    showLoadingDisplay('A sincronizar localizações');
    await LocationApi.instance.initialize();
    showLoadingDisplay('A carregar o menu');
    await getPickingTasks();
    await getMenuItemCards();
    hideLoadingDisplay();
    return true;
  }

  Future<void> getPickingTasks() async {
    pickingTasks = await PickingTaskApi.getByAccessId(1);
  }

  Future<void> getMenuItemCards() async {
    menuItemCards.clear();

    String menuTitle = '';

    for (final PickingTask item in pickingTasks) {
      if (menuTitle != item.group) {
        menuTitle = item.group;

        //Divider
        if (menuItemCards.isNotEmpty) {
          menuItemCards.add(
            const Divider(
              indent: 20.0,
              endIndent: 20.0,
              thickness: 1.0,
            ),
          );
        } else {
          menuItemCards.add(
            const SizedBox(
              height: 10.0,
            ),
          );
        }

        //Menu Title
        menuItemCards.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20.0,
                5.0,
                20.0,
                0.0,
              ),
              child: Text(
                item.group.toUpperCase(),
              ),
            ),
          ),
        );
      }

      menuItemCards.add(
        MenuItemCard(
          pickingTask: item,
          rebuildCallback: forceRebuild,
        ),
      );
    }
    menuItemCardsList = Column(children: menuItemCards);
  }

  Future<bool> forceRebuild() async {
    await _pullRefresh();
    return true;
  }

  Future<void> _pullRefresh() async {
    await getPickingTasks();
    await getMenuItemCards();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: kGreyBackground,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          leading: const Center(
            child: FaIcon(
              FontAwesomeIcons.house,
              color: kPrimaryColorLight,
            ),
          ),
          title: Text(
            'Menu Principal',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: kPrimaryColorLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
          titleSpacing: 0.0,
          elevation: 10.0,
          actions: [
            Row(
              children: [
                Text(
                  Helper.getWordFromPosition(
                    0,
                    System.instance.activeUser == null
                        ? ''
                        : System.instance.activeUser!.name,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: kPrimaryColorLight,
                      ),
                ),
                IconButton(
                  onPressed: () async {
                    System.instance.activeUser = null;
                    System.instance.token = null;
                    Navigator.pushNamed(context, LoginScreen.id);
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.rightFromBracket,
                    color: kPrimaryColorLight,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: LoadingDisplay(
          isLoading: showSpinner,
          loadingText: spinnerMessage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: FutureBuilder(
                  future: menuBuild,
                  builder: (context, snapshot) {
                    List<Widget> noSnapshotWidgets;
                    if (snapshot.hasData) {
                      return SingleChildScrollView(
                        child: menuItemCardsList,
                      );
                    } else if (snapshot.hasError &&
                        snapshot.connectionState != ConnectionState.waiting) {
                      noSnapshotWidgets = [
                        Icon(
                          Icons.error_outline,
                          color: kPrimaryColor.withOpacity(0.6),
                          size: 60,
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
