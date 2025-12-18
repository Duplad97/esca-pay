import 'package:flutter/material.dart';

class MoneyField extends StatelessWidget {
  const MoneyField({
    super.key,
    required this.controller,
    required this.label,
    required this.helper,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (String raw) {
        final parsed = double.tryParse(raw);
        if (parsed != null) onChanged(parsed);
      },
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        prefixText: 'Ft ',
      ),
    );
  }
}
