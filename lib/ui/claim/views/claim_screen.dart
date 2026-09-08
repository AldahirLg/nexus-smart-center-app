import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/claim/view_models/claim_screen_view_model.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';

class ClaimDeviceScreen extends StatelessWidget {
  final ClaimDeviceViewModel viewModel;
  const ClaimDeviceScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          switch (viewModel.step) {
            case ProvisioningStep.idle:
            case ProvisioningStep.connectingBle:
            case ProvisioningStep.requestingDeviceId:
            case ProvisioningStep.claimingToken:
            case ProvisioningStep.sendingCredentials:
            case ProvisioningStep.working:
            case ProvisioningStep.connectingWifi:
            case ProvisioningStep.testingWifi:
            case ProvisioningStep.awaitingServerConfirmation:
              return const Center(child: CircularProgressIndicator());
            case ProvisioningStep.failed:
              return const Center(
                child: Text('Conexión fallida, revisa contraseña Wi-Fi'),
              );
            case ProvisioningStep.timeout:
              return const Center(
                child: Text(
                  'El dispositivo tardó en responder, intenta de nuevo',
                ),
              );
            case ProvisioningStep.claimExpired:
              return const Center(
                child: Text('El claim expiró, intenta de nuevo'),
              );
            case ProvisioningStep.error:
              return const Center(
                child: Text('Ocurrió un error inesperado, intenta de nuevo'),
              );
            case ProvisioningStep.disconnected:
              return const Center(
                child: Text('El dispositivo se desconectó, intenta de nuevo'),
              );
            case ProvisioningStep.claimed:
              return const Center(child: Text('Configuración Exitosa'));
          }
        },
      ),
      showHeader: true,
      title: 'Vincular Dispositivo',
    );
  }
}
