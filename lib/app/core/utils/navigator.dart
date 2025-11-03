import 'package:flutter/material.dart';

final kGlobalKeyNavigator = GlobalKey<NavigatorState>();

class AppNavigator {
  static GlobalKey<NavigatorState> get key => kGlobalKeyNavigator;

  static BuildContext? get currentContext => key.currentContext;

  static NavigatorState? get state => key.currentState;

  static bool get hasValidContext {
    final context = currentContext;
    return context != null && context.mounted;
  }
}

bool isContextValid(BuildContext? context) {
  return context != null && context.mounted;
}
