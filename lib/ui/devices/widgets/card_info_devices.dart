import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class CardInfoDevices extends StatelessWidget {
  final int tinacoBateria;
  final bool tinacoSensor;
  final bool tinacoConexion;

  final bool cisternaSensor;

  const CardInfoDevices({
    super.key,
    required this.tinacoBateria,
    required this.tinacoSensor,
    required this.tinacoConexion,
    required this.cisternaSensor,
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
              const SizedBox(width: 12),
              Text(
                'Información de dispositivos',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: context.colors.outlineVariant),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _InfoTile(
                    icon: Icons.water_drop_outlined,
                    label: 'Tinaco',
                    statuses: [
                      _StatusData.battery(tinacoBateria),
                      _StatusData.sensor(tinacoSensor),
                      _StatusData.connection(tinacoConexion),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: context.colors.outlineVariant,
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    icon: Icons.water_drop_outlined,
                    label: 'Cisterna',
                    statuses: [_StatusData.sensor(cisternaSensor)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusData {
  final IconData icon;
  final String text;

  _StatusData({required this.icon, required this.text});

  factory _StatusData.battery(int percent) {
    IconData icon;
    if (percent <= 15) {
      icon = Icons.battery_alert_outlined;
    } else if (percent <= 50) {
      icon = Icons.battery_4_bar_outlined;
    } else {
      icon = Icons.battery_full_outlined;
    }
    return _StatusData(icon: icon, text: '$percent%');
  }

  factory _StatusData.sensor(bool ok) {
    return _StatusData(
      icon: ok ? Icons.sensors_outlined : Icons.sensors_off_outlined,
      text: ok ? 'Sensor OK' : 'Sensor falla',
    );
  }

  factory _StatusData.connection(bool online) {
    return _StatusData(
      icon: online ? Icons.wifi : Icons.wifi_off,
      text: online ? 'Conectado' : 'Sin conexión',
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<_StatusData> statuses;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    final subtleColor = context.colors.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: subtleColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...statuses.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: Icon(s.icon, size: 15, color: subtleColor),
                ),
                Expanded(
                  child: Text(
                    s.text,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: subtleColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
