import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hint;
  final InputBorder? inputBorder;
  final TextEditingController? controller;
  const CustomInput(
      {Key? key, this.onChanged, this.hint, this.inputBorder, this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged != null ?(v) => onChanged!(v) : null,
        decoration: InputDecoration(labelText: hint!, border: inputBorder),
        validator: (String? value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
    );
  }
}
