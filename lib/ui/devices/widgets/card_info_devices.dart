import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class CardInfoDevices extends StatelessWidget {
  final VoidCallback onTapTinaco;
  final VoidCallback onTapCisterna;
  const CardInfoDevices({
    super.key,
    required this.onTapTinaco,
    required this.onTapCisterna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: context.colors.surface,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: context.colors.shadow.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info,
                  size: 20,
                  color: context.colors.surface,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Información de dispositivos',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Tinaco',
                  onTap: onTapTinaco,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Cisterna',
                  onTap: onTapCisterna,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Material(
      color: context.colors.surfaceContainerHighest,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 20, color: context.colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: context.colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
