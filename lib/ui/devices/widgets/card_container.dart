import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class CardContainer extends StatelessWidget {
  final int percent;
  final String title;

  const CardContainer({super.key, required this.percent, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: context.colors.secondary,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(title),

          const SizedBox(height: 8),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: double.infinity,
                    color: context.colors.secondary,
                  ),

                  FractionallySizedBox(
                    widthFactor: 1,
                    heightFactor: percent.clamp(0, 100) / 100,
                    alignment: Alignment.bottomCenter,
                    child: Container(color: context.colors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('$percent %'),
        ],
      ),
    );
  }
}
