import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class AppHeader extends StatelessWidget {
  final String title;

  const AppHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: context.colors.primary,
            borderRadius: BorderRadius.circular(15),
          ),
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: context.colors.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
