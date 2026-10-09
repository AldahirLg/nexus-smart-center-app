import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class PanelButtonsPerfil extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const PanelButtonsPerfil({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: colors.shadow.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: child,
    );
  }
}
