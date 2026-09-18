import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class PanelParametersLc extends StatelessWidget {
  final int heightCis;
  final int heightTin;
  final int levelHigh;
  final int levelLow;
  final int minCis;
  const PanelParametersLc({
    super.key,
    required this.heightCis,
    required this.heightTin,
    required this.levelHigh,
    required this.levelLow,
    required this.minCis,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ConfigValueTile(label: 'Altura cisterna', value: heightCis),
        _ConfigDivider(),
        _ConfigValueTile(label: 'Altura tinaco', value: heightTin),
        _ConfigDivider(),
        _ConfigValueTile(label: 'Nivel alto', value: levelHigh),
        _ConfigDivider(),
        _ConfigValueTile(label: 'Nivel bajo', value: levelLow),
        _ConfigDivider(),
        _ConfigValueTile(label: 'Mínimo cisterna', value: minCis),
      ],
    );
  }
}

class _ConfigValueTile extends StatelessWidget {
  final String label;
  final int value;

  const _ConfigValueTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text('$value cm', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ConfigDivider extends StatelessWidget {
  const _ConfigDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: context.colors.outlineVariant,
    );
  }
}
