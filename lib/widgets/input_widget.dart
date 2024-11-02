import 'package:flutter/material.dart';

class InputWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String? initialValue;
  final IconData? icon;
  final int? maxLength;
  final int? maxLines;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool? obscure;
  final bool? enabled;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const InputWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.icon,
    this.initialValue,
    this.maxLines,
    this.onChanged,
    this.onTap,
    this.obscure,
    this.enabled,
    this.maxLength,
    this.keyboardType,
    this.suffixIcon,
  });

  @override
  State<InputWidget> createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    // final inputProvider = Provider.of<InputProvider>(context);
    return TextFormField(
      enabled: widget.enabled,
      obscureText: widget.obscure ?? false,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      maxLines: widget.maxLines,
      validator: (value) {
        if (value!.isEmpty) {
          return "الحقل فارغ";
        } else if (widget.maxLength != null) {
          if (value.length < widget.maxLength!) {
            return "يجب أن يكون الحد الأدنى ${widget.maxLength}!";
          } else if (value.length > widget.maxLength!) {
            return "يجب أن يكون الحد الأقصى ${widget.maxLength}!";
          }
        } else if (value.isNotEmpty) {
          return null;
        }
        return null;
      },
      initialValue: widget.initialValue,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      controller: widget.controller,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(10.0),
        labelText: widget.label,
        hintText: widget.hint,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                color: Colors.black,
                size: 18,
              )
            : null,
        suffixIcon: widget.suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
          borderRadius: BorderRadius.circular(10.0),
        ),
        floatingLabelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18.0,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
