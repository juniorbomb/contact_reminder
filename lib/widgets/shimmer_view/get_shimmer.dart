import 'package:contact_reminder/configs/colors.dart';
import 'package:flutter/material.dart';

import 'shimmer_view.dart';

getContactShimmer(BuildContext context, isPadding) {
  return Shimmer.fromColors(
    highlightColor: Colors.white10,
    baseColor: Colors.grey.shade400,
    enabled: true,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black45,),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 20,
            width: 20,
            margin: const EdgeInsets.only(right: 12),
            color: Colors.grey,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 8,
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
                 height: 8,
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
              height: 8,
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
