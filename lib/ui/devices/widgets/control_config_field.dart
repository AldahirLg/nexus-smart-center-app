import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class ConfigField extends StatelessWidget {
  final String label;
  final String initialValue;

  const ConfigField({
    super.key,
    required this.label,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: context.textTheme.bodyLarge,

        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.tertiary),
          borderRadius: BorderRadius.circular(12),
        ),

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.tertiary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
