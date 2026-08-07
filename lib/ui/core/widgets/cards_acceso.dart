import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class CardAcceso extends StatelessWidget {
  const CardAcceso({
    super.key,
    required this.icon,
    required this.title,
    required this.bodyText,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String bodyText;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: color.withValues(alpha: .2),
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              height: 50,
              width: 50,
              child: Icon(icon, color: color),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        textAlign: TextAlign.start,
                        title,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    textAlign: TextAlign.start,
                    bodyText,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(child: Icon(Icons.arrow_right)),
        ],
      ),
    );
  }
}
