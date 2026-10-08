import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

enum BombaMode { automatic, manual }

class BombaCard extends StatelessWidget {
  final BombaMode mode;
  final bool isOn;
  final ValueChanged<BombaMode> onModeChanged;
  final ValueChanged<bool> onPowerChanged;

  const BombaCard({
    super.key,
    required this.mode,
    required this.isOn,
    required this.onModeChanged,
    required this.onPowerChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isManual = mode == BombaMode.manual;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),

        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
            color: colors.shadow.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _tint(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.heat_pump,
                  size: 22,
                  color: isOn ? colors.primary : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Bomba',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusChip(isOn: isOn),
            ],
          ),
          const SizedBox(height: 16),
          _ModeSelector(mode: mode, onChanged: onModeChanged),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isManual
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _ManualControl(
                      isOn: isOn,
                      onChanged: onPowerChanged,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

Color _tint(BuildContext context) =>
    context.colors.surfaceContainerHighest.withValues(alpha: 0.6);

class _ModeSelector extends StatelessWidget {
  final BombaMode mode;
  final ValueChanged<BombaMode> onChanged;

  const _ModeSelector({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _tint(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeSegment(
              label: 'Manual',
              icon: Icons.edit_outlined,
              selected: mode == BombaMode.manual,
              onTap: () => onChanged(BombaMode.manual),
            ),
          ),
          Expanded(
            child: _ModeSegment(
              label: 'Automático',
              icon: Icons.auto_mode,
              selected: mode == BombaMode.automatic,
              onTap: () => onChanged(BombaMode.automatic),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeSegment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = selected ? colors.primary : colors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? colors.surface
              : colors.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              offset: const Offset(0, 2),
              color: colors.shadow.withValues(alpha: selected ? 0.08 : 0),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              Icon(icon, size: 16, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualControl extends StatelessWidget {
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const _ManualControl({required this.isOn, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _tint(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isOn ? 'Encendida' : 'Apagada',
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Switch(
            value: isOn,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: colors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: colors.outlineVariant,
            trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool isOn;

  const _StatusChip({required this.isOn});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isOn ? colors.primaryContainer : _tint(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOn ? 'ON' : 'OFF',
        style: context.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: isOn ? colors.onPrimaryContainer : colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
