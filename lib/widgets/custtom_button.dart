import 'package:flutter/material.dart';

class CusttomButton extends StatelessWidget {
  final String text;
  Size? minimumSize;
  TextStyle? textStyle;
  Color? backgroundColor;
  BorderSide? borderSide;
  final void Function()? onPressed;
  CusttomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.textStyle,
      this.borderSide,
      this.backgroundColor,
      this.minimumSize});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10.0,
          ),
        ),
        backgroundColor: backgroundColor,
        minimumSize: minimumSize,
        side: borderSide,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
