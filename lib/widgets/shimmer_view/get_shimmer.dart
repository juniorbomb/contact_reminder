import 'package:contact_reminder/configs/colors.dart';
import 'package:flutter/material.dart';

import '../../configs/dimensions.dart';
import 'shimmer_view.dart';

getContactShimmer(BuildContext context, isPadding) {
  final highLightColor = ColorPallet.primaryColor.withOpacity(0.1);
  final greyColor = Colors.grey.withOpacity(0.1);
  return Shimmer.fromColors(
    highlightColor: highLightColor,
    baseColor: greyColor,
    enabled: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black45,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: Dimensions.FONT_SIZE_LARGE,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey,
                  ),
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: Dimensions.FONT_SIZE_DEFAULT,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey,
                  ),
                  width: MediaQuery.of(context).size.width * 0.4,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 80,
              height: Dimensions.FONT_SIZE_LARGE,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
