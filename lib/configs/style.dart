import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_constants.dart';
import 'colors.dart';
import 'text_style.dart';

class Style {
  static ThemeData appTheme = ThemeData(
    primaryColor: ColorPallet.primaryColor,
    scaffoldBackgroundColor: ColorPallet.backgroundColor,
    fontFamily: AppConstants.FONT_FAMILY,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorPallet.transparent,
      foregroundColor: ColorPallet.transparent,
      elevation: 0,
      iconTheme: IconThemeData(
        color: ColorPallet.primaryColor,
      ),
      titleTextStyle: TextStyle(
        color: ColorPallet.primaryColor,
      ),
    ),
    iconTheme: const IconThemeData(
      color: ColorPallet.darkBlackColor,
    ),
    textTheme: TextTheme(
      bodyText1: TextStyles.bodyText(),
      headline1: TextStyles.headline1(),
      headline2: TextStyles.headline2(),
      headline3: TextStyles.headline3(),
      headline4: TextStyles.headline4(),
      headline5: TextStyles.headline5(),
      headline6: TextStyles.headline6(),
      headlineLarge: TextStyles.headlineLarge(),
    ),
  );

  static SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(
    systemNavigationBarColor: ColorPallet.backgroundColor,
    statusBarColor: ColorPallet.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,

    // Status bar brightness (optional)
    statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
    statusBarBrightness: Brightness.light, // For iOS (dark icons)
  );
}
