import 'package:flutter/material.dart';
import 'package:contact_reminder/configs/app_constants.dart';
import 'package:contact_reminder/configs/routes.dart';
import 'package:contact_reminder/configs/style.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.APP_NAME,
      theme: Style.appTheme,
      initialRoute: RouteList.INITIAL,
      routes: Routes.getAll(),
    );
  }
}
