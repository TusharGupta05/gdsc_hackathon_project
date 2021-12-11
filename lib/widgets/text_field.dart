import 'package:flutter/material.dart';

class TextEditingField extends StatelessWidget {
  const TextEditingField({
    Key? key,
    required this.controller,
    this.prefix,
    this.validator,
    this.hintText,
    this.borderRadius = 60,
    this.maxLines = 1,
    this.minLines = 1,
    this.suffix,
    this.onChanged,
  }) : super(key: key);
  final int? maxLines;
  final int? minLines;
  final double borderRadius;
  final TextEditingController controller;
  final Widget? prefix;
  final Widget? suffix;
  final String? hintText;
  final String? Function(String? s)? validator;
  final Function(String? s)? onChanged;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      obscuringCharacter: '*',
      controller: controller,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
          alignLabelWithHint: true,
          errorStyle: const TextStyle(height: 0.2),
          labelText: hintText,
          prefixIcon: prefix,
          suffixIcon: suffix,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius))),
    );
  }
}
