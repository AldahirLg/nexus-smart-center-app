import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';

class AddDeviceScreen extends StatelessWidget {
  const AddDeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(),
      showHeader: true,
      title: 'Agregar Dispositivo',
      showNavigationBar: false,
    );
  }
}
