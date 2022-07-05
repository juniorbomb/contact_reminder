import 'package:flutter/material.dart';
import 'package:contact_reminder/configs/app_constants.dart';
import 'package:contact_reminder/configs/routes.dart';
import 'package:contact_reminder/configs/style.dart';
// import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

void main() {
  // SmsQuery query = SmsQuery();
  runApp(const MyApp());
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
