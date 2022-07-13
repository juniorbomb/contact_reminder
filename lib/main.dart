import 'package:flutter/material.dart';
import 'package:contact_reminder/configs/app_constants.dart';
import 'package:contact_reminder/configs/routes.dart';
import 'package:contact_reminder/configs/style.dart';
import 'package:flutter/services.dart';

void main() async {
  // final directory = await getApplicationDocumentsDirectory();
  // Hive.init(directory.path);
  SystemChrome.setSystemUIOverlayStyle(Style.systemUiOverlayStyle);

  // Workmanager().initialize(
  //     callbackDispatcher, // The top level function, aka callbackDispatcher
  //     isInDebugMode:
  // !kReleaseMode // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  //     );
  // Workmanager().registerOneOffTask("task-identifier", "simpleTask");
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
