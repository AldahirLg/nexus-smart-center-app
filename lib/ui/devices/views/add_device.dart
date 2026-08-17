import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/devices/view_models/add_device_view_model.dart';

class AddDeviceScreen extends StatefulWidget {
  final AddDeviceViewModel viewModel;
  const AddDeviceScreen({super.key, required this.viewModel});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  @override
  void initState() {
    super.initState();

    widget.viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (widget.viewModel.claimStatus == ClaimStatus.claimSuccess) {
      if (!mounted) return;

      context.go(Routes.home);
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return Column(
            children: [
              if (widget.viewModel.claimStatus == ClaimStatus.loading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: widget.viewModel.initClaimDevice,
                  child: const Text('Claim'),
                ),

              if (widget.viewModel.messageError != null)
                Text(widget.viewModel.messageError!),
            ],
          );
        },
      ),
      showHeader: true,
      title: 'Agregar Dispositivo',
      showNavigationBar: false,
    );
  }
}
