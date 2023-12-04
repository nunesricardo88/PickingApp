import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:n6picking_flutterapp/screens/configure_endpoint_screen.dart';
import 'package:n6picking_flutterapp/screens/loading_screen.dart';
import 'package:n6picking_flutterapp/screens/login_screen.dart';
import 'package:n6picking_flutterapp/screens/main_menu_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';

void main() {
  runApp(N6Picking());
}

class N6Picking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Intl.defaultLocale = 'pt_PT';
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('pt', 'PT'),
      ],
      debugShowCheckedModeBanner: false,
      theme: defaultThemeData,
      initialRoute: LoadingScreen.id,
      routes: {
        LoadingScreen.id: (context) => LoadingScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        ConfigureEndpointScreen.id: (context) => ConfigureEndpointScreen(),
        MainMenuScreen.id: (context) => MainMenuScreen(),
      },
    );
  }
}
