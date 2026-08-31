import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/claim/view_models/ble_scan_view_model.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:universal_ble/universal_ble.dart';

class BleScanScreen extends StatelessWidget {
  final BleScanViewModel viewmodel;
  const BleScanScreen({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewmodel,
        builder: (context, chidl) {
          if (viewmodel.adapterState == AvailabilityState.poweredOff) {
            return Center(child: Text('Bluetooth desactivado'));
          }
          return ListView.builder(
            itemCount: viewmodel.devices.length,
            itemBuilder: (context, index) {
              BleDevice device = viewmodel.devices[index];
              return ListTile(title: Text(device.name ?? "Desconocido"));
            },
          );
        },
      ),
      showHeader: true,
      showNavigationBar: false,
      title: "Escanear",
    );
  }
}
