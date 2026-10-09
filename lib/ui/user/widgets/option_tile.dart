import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class OptionTilePerfil extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const OptionTilePerfil({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final iconColor = color ?? colors.onSurface;
    final textColor = color ?? colors.onSurface;
    final iconBackground =
        color?.withValues(alpha: 0.12) ??
        colors.surfaceContainerHighest.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: iconBackground,
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
