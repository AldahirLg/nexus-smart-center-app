import 'package:flutter/material.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/utils/device_Icon_mapper.dart';

class DeviceManagementTile extends StatelessWidget {
  const DeviceManagementTile({
    super.key,
    required this.device,
    required this.onEdit,
    required this.onDelete,
    this.enabled = true,
  });

  final DeviceModel device;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              DeviceIconMapper.getIcon(device.type),
              size: 28,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  device.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  DeviceIconMapper.getTypeString(device.type),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Cambiar nombre',
            onPressed: enabled ? onEdit : null,
            icon: const Icon(Icons.edit_outlined),
            color: colors.primary,
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            tooltip: 'Eliminar dispositivo',
            onPressed: enabled ? onDelete : null,
            icon: const Icon(Icons.delete_outline_rounded),
            color: colors.error,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
