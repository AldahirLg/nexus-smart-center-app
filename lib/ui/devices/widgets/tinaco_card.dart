import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class TinacoCard extends StatelessWidget {
  final int level;
  final bool sensor;
  final bool connection;
  final int battery;
  final String title;

  const TinacoCard({
    super.key,
    required this.level,
    required this.sensor,
    required this.connection,
    required this.battery,
    this.title = 'Tinaco',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = (level / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: colors.shadow.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TankGauge(progress: progress),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: context.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '$level %',
                    style: context.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: sensor ? Icons.check_circle : Icons.cancel,
                    label: 'Sensor',
                    ok: sensor,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: connection ? Icons.check_circle : Icons.cancel,
                    label: 'Conexion',
                    ok: connection,
                  ),
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: _batteryIcon(battery),
                    label: 'Batería $battery %',
                    ok: battery > 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _batteryIcon(int value) {
    if (value > 80) return Icons.battery_full;
    if (value > 50) return Icons.battery_5_bar;
    if (value > 20) return Icons.battery_3_bar;
    return Icons.battery_alert;
  }
}

class _TankGauge extends StatelessWidget {
  final double progress;
  const _TankGauge({required this.progress});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const radius = 14.0;

    return Container(
      width: 110,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: colors.primary.withValues(alpha: 0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => FractionallySizedBox(
              heightFactor: value,
              widthFactor: 1,
              child: Container(
                decoration: BoxDecoration(color: context.colors.primary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool ok;

  const _InfoRow({required this.icon, required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    final color = ok ? context.colors.primary : context.colors.error;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
