import 'package:flutter/material.dart';

/// 无边框文本输入框
/// 适用于面板内部的输入区域，没有外边框
class BorderlessTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final int? minLines;
  final int? maxLines;
  final TextStyle? style;

  const BorderlessTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.readOnly = false,
    this.minLines,
    this.maxLines,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: hintText,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: const EdgeInsets.only(right: 12),
        filled: false,
      ),
      style: style ?? const TextStyle(fontSize: 15, height: 1.8),
      onChanged: onChanged,
    );
  }
}
