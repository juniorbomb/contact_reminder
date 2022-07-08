import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../configs/colors.dart';
import '../configs/dimensions.dart';

class ThemeInputField extends StatelessWidget {
  const ThemeInputField({
    Key? key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.spacing = const EdgeInsets.symmetric(horizontal: 12),
    this.inputFormatters,
    this.keyboardType,
    this.textInputAction,
    this.isSuffix = false,
    this.autofocus = false,
    this.showDivider = true,
    this.node,
    this.backgroundColor = ColorPallet.whiteColor,
    this.borderColor = ColorPallet.blackShadowColor,
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: Dimensions.FONT_SIZE_DEFAULT,
      fontWeight: FontWeight.w500,
    ),
    this.hintStyle = const TextStyle(
      color: Colors.black54,
      fontSize: Dimensions.FONT_SIZE_DEFAULT,
      fontWeight: FontWeight.w500,
    ),
    this.validator,
    this.suffixIcon,
    this.maxLength,
    this.separatorVisible = true,
    this.readOnly = false,
    this.obscureText = false,
    this.onTap,
  }) : super(key: key);
  final String hint;
  final Widget icon;
  final EdgeInsetsGeometry spacing;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController controller;
  final bool isSuffix;
  final bool showDivider;
  final bool readOnly;
  final bool autofocus;
  final bool obscureText;
  final Widget? suffixIcon;
  final Color borderColor;
  final Color backgroundColor;
  final TextStyle hintStyle;
  final TextStyle textStyle;
  final int? maxLength;
  final FocusNode? node;

  final String? Function(String?)? validator;
  final Function()? onTap;

  final bool separatorVisible;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          icon,
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: separatorVisible ? 12 : 6),
            child: Visibility(
              visible: separatorVisible,
              child: const VerticalLine(),
            ),
          ),
          Expanded(
            child: TextFormField(
              readOnly: readOnly,
              controller: controller,
              focusNode: node,
              style: textStyle,
              maxLength: maxLength,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              inputFormatters: inputFormatters,
              validator: validator,
              onTap: onTap,
              autofocus: autofocus,
              obscureText: obscureText,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                counterText: "",
                fillColor: backgroundColor,
                contentPadding: EdgeInsets.zero,
                hintStyle: hintStyle,
              ),
            ),
          ),
          if (isSuffix) suffixIcon ?? const SizedBox()
        ],
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 1),
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, 2),
            spreadRadius: 0,
            color: ColorPallet.blackShadowColor.withOpacity(0.08),
          )
        ],
      ),
    );
  }
}

class VerticalLine extends StatelessWidget {
  const VerticalLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      height: 30,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xffffffff), Color(0xff323232), Color(0xffffffff)],
            stops: [0.10, 0.5, 0.90],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
      ),
    );
  }
}
