import 'package:flutter/material.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/devices/view_models/manage_devices_mode_view.dart';
import 'package:provider/provider.dart';

class ManageDevicesScreen extends StatelessWidget {
  const ManageDevicesScreen({super.key});

  Future<void> _editName(BuildContext context, DeviceModel device) async {
    final vm = context.read<ManageDevicesModeView>();
    final messenger = ScaffoldMessenger.of(context);

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: device.name),
    );
    if (newName == null) return;

    final ok = await vm.updateDeviceName(device, newName);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Nombre actualizado'
              : (vm.errorMessage ?? 'No se realizaron cambios'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManageDevicesModeView>();

    Widget content;
    if (vm.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (vm.errorMessage != null && vm.devices.isEmpty) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(vm.errorMessage!),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: vm.getDevices,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    } else if (vm.devices.isEmpty) {
      content = const Center(child: Text('No hay dispositivos'));
    } else {
      content = RefreshIndicator(
        onRefresh: vm.getDevices,
        child: ListView.separated(
          itemCount: vm.devices.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final device = vm.devices[i];
            return ListTile(
              title: Text(device.name),
              trailing: IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Cambiar nombre',
                onPressed: vm.isUpdating
                    ? null
                    : () => _editName(context, device),
              ),
            );
          },
        ),
      );
    }

    return AppScaffold(
      showHeader: true,
      title: 'Gestion de dispositivos',
      body: Column(
        children: [
          if (vm.isUpdating) const LinearProgressIndicator(),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _EditNameDialog extends StatefulWidget {
  const _EditNameDialog({required this.initialName});
  final String initialName;

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cambiar nombre'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          maxLength: 30,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Nombre del dispositivo',
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
