import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

enum BombaMode { automatic, manual }

class BombaCard extends StatefulWidget {
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
  State<BombaCard> createState() => _BombaCardState();
}

class _BombaCardState extends State<BombaCard> {
  @override
  Widget build(BuildContext context) {
    final isManual = widget.mode == BombaMode.manual;

    return Container(
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.heat_pump,
                    color: widget.isOn
                        ? context.colors.primary
                        : context.colors.outline,
                  ),
                  const SizedBox(width: 8),
                  Text('Bomba', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              _StatusChip(isOn: widget.isOn),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SegmentedButton<BombaMode>(
                segments: const [
                  ButtonSegment(
                    value: BombaMode.automatic,
                    label: Text('Automático'),
                    icon: Icon(Icons.auto_mode),
                  ),
                  ButtonSegment(
                    value: BombaMode.manual,
                    label: Text('Manual'),
                    icon: Icon(Icons.touch_app_outlined),
                  ),
                ],
                selected: {widget.mode},
                onSelectionChanged: (s) => widget.onModeChanged(s.first),
              ),
            ],
          ),

          // Control directo, solo visible en manual
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isManual
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _ManualControl(
                      isOn: widget.isOn,
                      onChanged: widget.onPowerChanged,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(isOn ? 'Encendida' : 'Apagada'),
          Switch(value: isOn, onChanged: onChanged),
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
    final label = isOn ? 'ON' : 'OFF';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOn
            ? context.colors.primaryContainer
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
