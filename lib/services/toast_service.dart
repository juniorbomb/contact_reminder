import 'package:contact_reminder/configs/colors.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../configs/dimensions.dart';

class ToastService {
  static show(String message, {toastLength = Toast.LENGTH_SHORT}) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM,
      toastLength: toastLength,
      timeInSecForIosWeb: 1,
      backgroundColor: ColorPallet.darkBlackColor,
      textColor: ColorPallet.whiteColor,
      fontSize: Dimensions.FONT_SIZE_DEFAULT,
    );
  }
}
