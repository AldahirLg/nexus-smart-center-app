import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/claim_repository.dart';
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
          switch (viewModel.state) {
            case StateProvisioning.connectingBle:
            case StateProvisioning.working:
            case StateProvisioning.connectingWifi:
            case StateProvisioning.testingWifi:
              return Center(child: CircularProgressIndicator());
            case StateProvisioning.failed:
              return Center(
                child: Text('Conexion fallida, revisa constraseña Wi-Fi'),
              );
            case StateProvisioning.timeout:
              return Center(
                child: Text('El dispositivo tardo en responde intena de nuevo'),
              );
            case StateProvisioning.error:
              return Center(
                child: Text('Ocurrio un error inesperado, intenta de nuevo'),
              );
            default:
              return Center(child: Text('Configuracion Exitosa'));
          }
        },
      ),
      showHeader: true,
      title: 'Vincular Dispositivo',
      showNavigationBar: false,
    );
  }
}
