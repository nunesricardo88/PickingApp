import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:n6picking_flutterapp/models/api_response.dart';
import 'package:n6picking_flutterapp/models/user_model.dart';
import 'package:n6picking_flutterapp/screens/configure_endpoint_screen.dart';
import 'package:n6picking_flutterapp/screens/main_menu_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/helper.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _pinPutFocusNode = FocusNode();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  List<User> _usersList = [];
  late User _selectedUser;
  bool _canLogin = false;
  bool _isOnline = false;
  bool _isUpToDate = false;
  bool _firstSetup = true;

  bool isPinFull = false;
  bool isPinEmpty = true;
  bool showSpinner = false;

  @override
  void initState() {
    super.initState();
    checkIfCanLogin();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> checkIfCanLogin() async {
    setState(() => showSpinner = true);

    bool canLogin = false;
    bool isOnline = false;
    bool isUpToDate = false;

    isOnline = await checkIfIsOnline();
    isUpToDate = await checkIfIsUpToDate();
    canLogin = isOnline && isUpToDate;

    if (canLogin) {
      await getUsers();
    } else {
      _usersList.clear();
    }

    setState(() {
      _isOnline = isOnline;
      _isUpToDate = isUpToDate;
      _canLogin = canLogin;
      _firstSetup = false;
      showSpinner = false;
    });
  }

  Future<bool> checkIfIsOnline() async {
    return System.instance.checkIfUpToDate();
  }

  Future<bool> checkIfIsUpToDate() async {
    return System.instance.checkIfUpToDate();
  }

  Future<void> getUsers() async {
    _usersList.clear();
    _usersList = await UserApi.getAll();
  }

  Future<void> callConfigureEndpointScreen() async {
    setState(() => showSpinner = true);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: ConfigureEndpointScreen(),
        );
      },
    ).whenComplete(() => checkIfCanLogin());

    setState(() => showSpinner = false);
  }

  Future<bool> login() async {
    bool success = false;
    if (_canLogin) {
      setState(() => showSpinner = true);

      final ApiResponse response =
          await System.instance.login(_selectedUser, _pinController.text);

      success = response.success;

      if (success) {
        _usernameController.clear();
        _pinController.clear();
        gotoMainMenu();
      } else {
        _pinController.clear();
        final Map<String, dynamic> errorMap =
            jsonDecode(response.result as String) as Map<String, dynamic>;
        final String errorMessage = errorMap['errorCode'] as String;

        // ignore: use_build_context_synchronously
        await Helper.showMsg("Login falhou!", errorMessage, context);
      }

      setState(() => showSpinner = false);
    }
    return success;
  }

  void gotoMainMenu() {
    Navigator.pushNamed(context, MainMenuScreen.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorLight,
      body: LoadingOverlay(
        color: Colors.black.withOpacity(0.7),
        isLoading: showSpinner,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 10.0,
                            ),
                            child: GestureDetector(
                              onLongPress: () {
                                callConfigureEndpointScreen();
                              },
                              child: IconButton(
                                iconSize: 30.0,
                                onPressed: () {},
                                icon: const FaIcon(
                                  FontAwesomeIcons.gear,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: _isOnline ? 40.0 : 0.0),
                      SizedBox(
                        height: 100.0,
                        child: Image.asset('images/logo_n6logistics.png'),
                      ),
                      const SizedBox(height: 35.0),
                      if (!_isOnline && !_firstSetup)
                        Column(
                          children: [
                            Center(
                              child: Text(
                                'Sem ligação',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      color: kErrorColor,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                            ),
                            IconButton(
                              padding: const EdgeInsets.only(top: 15.0),
                              iconSize: 30.0,
                              color: kErrorColor,
                              icon: const FaIcon(FontAwesomeIcons.arrowsRotate),
                              onPressed: () {
                                checkIfCanLogin();
                              },
                            ),
                          ],
                        )
                      else if (!_isUpToDate && !_firstSetup)
                        Column(
                          children: [
                            Center(
                              child: Text(
                                'Nova Versão Disponível: ${System.instance.apiVersion?.join(".")}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Center(
                              child: Text(
                                'Por favor, atualize a aplicação',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                padding: const EdgeInsets.symmetric(
                                  //horizontal: 20.0,
                                  vertical: 5.0,
                                ),
                                decoration: pinPutDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: GestureDetector(
                                  onTap: () async {
                                    setState(() => showSpinner = true);
                                    await _showListUsersDialog().then((value) {
                                      if (value != null) {
                                        final User user = value as User;
                                        final String username = user.name;
                                        setState(() {
                                          _usernameController.text = username;
                                          _selectedUser = user;
                                        });
                                      }
                                    });
                                    setState(() => showSpinner = false);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Flexible(
                                        child: TextField(
                                          enabled: false,
                                          controller: _usernameController,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Insira o Utilizador',
                                            hintStyle: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  color: kPrimaryColorDark
                                                      .withOpacity(0.5),
                                                ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 15.0,
                                            ),
                                            prefixIcon: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                              ),
                                              child: Icon(
                                                FontAwesomeIcons.user,
                                                color: kPrimaryColor,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(10.0),
                                        child: Icon(Icons.arrow_drop_down),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 15.0),
                                decoration: pinPutDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                                child: TextField(
                                  focusNode: _pinPutFocusNode,
                                  enableInteractiveSelection: false,
                                  controller: _pinController,
                                  keyboardType: TextInputType.number,
                                  obscureText: true,
                                  obscuringCharacter: '●',
                                  maxLength: 4,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (value) async {
                                    await _login();
                                  },
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    counter: const Offstage(),
                                    hintText: 'Insira o Pin',
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: kPrimaryColorDark
                                              .withOpacity(0.5),
                                        ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                    ),
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                      child: Icon(
                                        FontAwesomeIcons.key,
                                        color: kPrimaryColor,
                                        size: 25,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 40.0),
                                width: double.infinity,
                                decoration: pinPutDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(16.0),
                                  color: kPrimaryColor,
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    await _login();
                                  },
                                  child: const Text(
                                    'Entrar',
                                    style: TextStyle(
                                      color: kIconColor,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 2.0, bottom: 5.0, right: 5.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    'v. ${System.instance.appVersion}',
                    style: const TextStyle(
                      letterSpacing: 0,
                      fontSize: 9.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _pinController.text.isEmpty) {
      return _showAlertDialog()
          .whenComplete(() => setState(() => _pinController.clear()));
    } else {
      final bool success = await login();
      if (success) {
      } else {
        return;
      }
    }
  }

  Future<void> _showAlertDialog() async => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Falhou'),
            content:
                const Text('Os campos de utilizador e pin são obrigatórios.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );

  Future<dynamic> _showListUsersDialog() async => showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.only(left: 5.0, right: 5.0),
            title: Text(_isOnline ? 'Utilizadores' : 'Falha na ligação'),
            content: !_isOnline
                ? const Text(
                    'Não foi possível encontrar utilizadores. Por favor, verifique a ligação à internet ou ao servidor.',
                  )
                : _usersList.isEmpty
                    ? const Text(
                        'Não foram encontrados utilizadores. Por favor, verifique se algum utilizador tem acesso à aplicação.',
                      )
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 10.0),
                            for (final User user in _usersList)
                              Column(
                                children: [
                                  const Divider(
                                    height: 1.0,
                                    indent: 30.0,
                                    endIndent: 30.0,
                                    color: kPrimaryColorLight,
                                  ),
                                  ListTile(
                                    title: Center(
                                      child: Text(
                                        user.name,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context, user);
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
            actions: [
              if (!_isOnline || _usersList.isEmpty)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok'),
                ),
            ],
          );
        },
      );
}
