// ignore_for_file: depend_on_referenced_packages

import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:n6picking_flutterapp/screens/login_screen.dart';
import 'package:n6picking_flutterapp/utilities/constants.dart';
import 'package:n6picking_flutterapp/utilities/system.dart';
import 'package:page_transition/page_transition.dart';

class LoadingScreen extends StatefulWidget {
  static const String id = 'loading_screen';

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenFunction(
      backgroundColor: kGreyBackground,
      splash: 'images/logo_n6logistics.png',
      screenFunction: () async {
        await System.instance.initialize();
        return LoginScreen();
      },
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}
