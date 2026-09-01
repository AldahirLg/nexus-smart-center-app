import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/claim/view_models/ble_scan_view_model.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';

class BleScanScreen extends StatelessWidget {
  final BleScanViewModel viewmodel;
  const BleScanScreen({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "Escanear",
      showHeader: true,
      showNavigationBar: false,
      body: ListenableBuilder(
        listenable: viewmodel,
        builder: (context, _) {
          final vm = viewmodel;

          if (vm.adapterState != BluetoothAdapterState.on) {
            return _AdapterOffView(state: vm.adapterState);
          }

          return Column(
            children: [
              _ScanHeader(
                isScanning: vm.isScanning,
                deviceCount: vm.results.length,
                onToggle: vm.toggleScan,
              ),
              if (vm.isScanning) const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: vm.results.isEmpty
                    ? _EmptyResultsView(
                        isScanning: vm.isScanning,
                        onScan: vm.startScan,
                      )
                    : RefreshIndicator(
                        onRefresh: vm.startScan,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: vm.results.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final result = vm.results[index];
                            return _DeviceTile(
                              result: result,
                              onTap: () {
                                vm.stopScan();
                                context.push(
                                  Routes.claimDevice,
                                  extra: result.device,
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScanHeader extends StatelessWidget {
  final bool isScanning;
  final int deviceCount;
  final VoidCallback onToggle;

  const _ScanHeader({
    required this.isScanning,
    required this.deviceCount,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isScanning
                  ? 'Buscando dispositivos...'
                  : deviceCount == 0
                  ? 'Sin dispositivos encontrados'
                  : '$deviceCount dispositivo${deviceCount == 1 ? '' : 's'} encontrado${deviceCount == 1 ? '' : 's'}',
              style: theme.textTheme.titleSmall,
            ),
          ),
          FilledButton.tonalIcon(
            onPressed: onToggle,
            icon: isScanning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bluetooth_searching, size: 18),
            label: Text(isScanning ? 'Detener' : 'Buscar'),
          ),
        ],
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final ScanResult result;
  final VoidCallback onTap;

  const _DeviceTile({required this.result, required this.onTap});

  String get _displayName {
    final advName = result.advertisementData.advName;
    if (advName.isNotEmpty) return advName;
    final platformName = result.device.platformName;
    if (platformName.isNotEmpty) return platformName;
    return 'Dispositivo desconocido';
  }

  (IconData, Color) _signal(BuildContext context) {
    final rssi = result.rssi;
    if (rssi >= -60) {
      return (Icons.signal_cellular_alt, Colors.green);
    } else if (rssi >= -75) {
      return (Icons.signal_cellular_alt_2_bar, Colors.orange);
    } else {
      return (Icons.signal_cellular_alt_1_bar, Colors.redAccent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _signal(context);

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            Icons.bluetooth,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          _displayName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(result.device.remoteId.str),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(icon, color: color, size: 20),
            Text(
              '${result.rssi} dBm',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EmptyResultsView extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onScan;

  const _EmptyResultsView({required this.isScanning, required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bluetooth_searching,
              size: 56,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isScanning
                  ? 'Buscando dispositivos cercanos...'
                  : 'No se encontraron dispositivos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Asegúrate de que el dispositivo esté encendido y cerca de tu teléfono.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (!isScanning) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.refresh),
                label: const Text('Buscar de nuevo'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AdapterOffView extends StatelessWidget {
  final BluetoothAdapterState state;
  const _AdapterOffView({required this.state});

  Future<void> _tryTurnOn() async {
    try {
      await FlutterBluePlus.turnOn();
    } catch (_) {
      // En iOS no se puede activar programáticamente; se ignora.
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = switch (state) {
      BluetoothAdapterState.off => 'Bluetooth desactivado',
      BluetoothAdapterState.unauthorized =>
        'La app no tiene permiso para usar Bluetooth',
      BluetoothAdapterState.unavailable =>
        'Este dispositivo no soporta Bluetooth',
      _ => 'Bluetooth no disponible',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (state == BluetoothAdapterState.off) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _tryTurnOn,
                icon: const Icon(Icons.bluetooth),
                label: const Text('Activar Bluetooth'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
