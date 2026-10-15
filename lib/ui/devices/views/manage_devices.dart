import 'package:flutter/material.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/devices/view_models/manage_devices_mode_view.dart';
import 'package:nexus_smart_center/ui/devices/widgets/device_management_tile.dart';
import 'package:nexus_smart_center/ui/user/widgets/option_tile.dart';
import 'package:nexus_smart_center/ui/user/widgets/panel_content.dart';
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

    return AppScaffold(
      showHeader: true,
      title: 'Gestión de dispositivos',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (vm.isUpdating) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
            ],
            PanelButtonsPerfil(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _buildContent(vm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ManageDevicesModeView vm) {
    if (vm.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.errorMessage != null && vm.devices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(vm.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: vm.getDevices,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (vm.devices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('No hay dispositivos')),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vm.devices.length,
      padding: const EdgeInsets.all(12),
      separatorBuilder: (_, __) => Divider(height: 1, thickness: 1),
      itemBuilder: (context, i) {
        final device = vm.devices[i];

        return DeviceManagementTile(
          device: device,
          enabled: !vm.isUpdating,
          onEdit: () => _editName(context, device),
          onDelete: () => _deleteDevice(context, device),
        );
      },
    );
  }
}

Future<void> _deleteDevice(BuildContext context, DeviceModel device) async {
  final vm = context.read<ManageDevicesModeView>();
  final messenger = ScaffoldMessenger.of(context);

  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Eliminar dispositivo'),
      content: Text(
        '¿Deseas eliminar "${device.name}"? '
        'Esta acción no se puede deshacer.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirm != true || !context.mounted) return;

  final success = await vm.deleteDevice(device);

  if (!context.mounted) return;

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        success
            ? 'Dispositivo eliminado correctamente'
            : (vm.errorMessage ?? 'No se pudo eliminar el dispositivo'),
      ),
    ),
  );
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
