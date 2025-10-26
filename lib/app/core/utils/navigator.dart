import 'package:flutter/material.dart';

final kGlobalKeyNavigator = GlobalKey<NavigatorState>();

class AppNavigator {
  static GlobalKey<NavigatorState> get key => kGlobalKeyNavigator;

  static BuildContext? get currentContext => key.currentContext;

  static NavigatorState? get state => key.currentState;
}
