import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TextEditingField extends StatelessWidget {
  const TextEditingField({
    Key? key,
    required this.controller,
    this.prefix,
    this.isPassword = false,
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
  final bool isPassword;
  final String? hintText;
  final String? Function(String? s)? validator;
  final Function(String? s)? onChanged;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PasswordVisibility>(
        create: (_) => PasswordVisibility(isPassword),
        builder: (_, __) => SingleChildScrollView(
              child: Consumer<PasswordVisibility>(
                  builder: (_, passwordVisibility, __) {
                return TextFormField(
                  onChanged: onChanged,
                  maxLines: maxLines,
                  minLines: minLines,
                  validator: validator,
                  obscureText: !passwordVisibility.isVisible,
                  obscuringCharacter: '*',
                  controller: controller,
                  textAlignVertical: TextAlignVertical.top,
                  // expands: true,
                  decoration: InputDecoration(
                      alignLabelWithHint: true,
                      errorStyle: const TextStyle(height: 0.2),
                      labelText: hintText,
                      prefixIcon: prefix,
                      suffixIcon: suffix ??
                          (isPassword
                              ? IconButton(
                                  splashRadius: 20,
                                  onPressed: () {
                                    passwordVisibility.changeVisibility();
                                  },
                                  icon: passwordVisibility.isVisible
                                      ? const Icon(Icons.visibility)
                                      : const Icon(Icons.visibility_off))
                              : null),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(borderRadius))),
                );
              }),
            ));
  }
}

class PasswordVisibility with ChangeNotifier {
  bool isVisible = true;
  bool isPassword;
  PasswordVisibility(this.isPassword) {
    if (isPassword) {
      isVisible = false;
    }
  }
  void changeVisibility() {
    if (isPassword) {
      isVisible = !isVisible;
      notifyListeners();
    }
  }
}
