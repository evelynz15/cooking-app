import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? hint;
  final InputBorder? inputBorder;
  final TextEditingController? controller;
  final bool? mustBeNumber;
  final int? maxLength;
  const CustomInput(
      {Key? key,
      this.onChanged,
      this.hint,
      this.inputBorder,
      this.controller,
      this.mustBeNumber,
      this.maxLength})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        maxLines: null,
        keyboardType: mustBeNumber == true
            ? TextInputType.numberWithOptions(decimal: true)
            : null,
        inputFormatters: [
          mustBeNumber == true
              ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
              : FilteringTextInputFormatter.deny(RegExp(r'')),
        ],
        onChanged: onChanged != null ? (v) => onChanged!(v) : null,
        decoration: InputDecoration(
          labelText: hint!,
          labelStyle: TextStyle(fontSize: 12), 
          border: inputBorder
          ),
        validator: (String? value) {
          if (mustBeNumber == true) {
            if (value == null || value.isEmpty || value.isNum != true) {
              return 'Please enter a number';
            } else {
              return null;
            }
          } else {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            } else {
              return null;
            }
          }
        },
      ),
    );
  }
}
