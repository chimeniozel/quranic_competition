import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';

class CusttomButton extends StatelessWidget {
  final String text;
  Size? minimumSize;
  TextStyle? style;
  Color? backgroundColor;
  final void Function()? onPressed;
  CusttomButton(
      {super.key,
      required this.text,
      required this.onPressed,
      this.style,
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
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: style,
      ),
    );
  }
}
