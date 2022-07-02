// Routes
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:set_up/screens/nav/nav.dart';

GlobalKey<NavigatorState>? navigatorKey = GlobalKey<NavigatorState>();

class RouteList {
  static const String INITIAL = "/";
  static const String NAV = "/navigation";
  static const String HOME = "/home";
}

class Routes {
  static Map<String, WidgetBuilder> getAll() => _routes;

  static final Map<String, WidgetBuilder> _routes = {
    "/": (ctx) => const NavigationScreen(),
    RouteList.HOME: (context) => Container(),
    RouteList.NAV: (context) => const NavigationScreen(),
  };

  static Route getRouteGenerate(RouteSettings settings) {
    // var routingData = settings.arguments;

    return _errorRoute("Ops! Page Not found!");
  }

  static MaterialPageRoute _buildRoute(
      RouteSettings settings, WidgetBuilder builder,
      {bool fullScreenDialog = false}) {
    return MaterialPageRoute(
      settings: settings,
      builder: builder,
      fullscreenDialog: fullScreenDialog,
    );
  }

  static Route _errorRoute([String message = 'Page not founds']) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(message),
        ),
      );
    });
  }
}
