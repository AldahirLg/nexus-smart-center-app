import 'package:flutter/material.dart';
import 'package:nexus_smart_center/models/level_controller_model.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/devices/view_models/control_de_nivel_model_view.dart';
import 'package:nexus_smart_center/ui/devices/widgets/bomba_card.dart';
import 'package:nexus_smart_center/ui/devices/widgets/card_container.dart';
import 'package:nexus_smart_center/ui/devices/widgets/card_info_devices.dart';
import 'package:nexus_smart_center/ui/devices/widgets/edit_parameters_LC.dart';
import 'package:nexus_smart_center/ui/devices/widgets/panel_parameters_LC.dart';
import 'package:provider/provider.dart';

class ControlDeNivelScreen extends StatefulWidget {
  const ControlDeNivelScreen({super.key});

  @override
  State<ControlDeNivelScreen> createState() => _ControlDeNivelScreenState();
}

class _ControlDeNivelScreenState extends State<ControlDeNivelScreen> {
  int _currentIndex = 0;

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ControlDeNivelModelViewModel>();

    final levelController = viewModel.levelController;

    if (levelController == null) {
      if (viewModel.isLoading) {
        return const AppScaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return AppScaffold(
        body: Center(
          child: Text(viewModel.errorMessage ?? 'No se pudo cargar'),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _ControlHomePage(viewModel: viewModel),
          _ControlSettingPage(viewModel: viewModel),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 20),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined, size: 20),
            activeIcon: Icon(Icons.settings),
            label: 'Ver más',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: context.colors.primary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        onTap: _onNavigationTap,
      ),
    );
  }
}

class _ControlHomePage extends StatelessWidget {
  final ControlDeNivelModelViewModel viewModel;
  const _ControlHomePage({required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showHeader: true,
      title: viewModel.device.name,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CardContainer(
                    percent: viewModel.levelController!.status.tinLevel,
                    title: 'Tinaco',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CardContainer(
                    percent: viewModel.levelController!.status.cisLevel,
                    title: 'Cisterna',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            BombaCard(
              mode: viewModel.levelController!.pump.mode == 'AUTO'
                  ? BombaMode.automatic
                  : BombaMode.manual,
              isOn: viewModel.levelController!.pump.isOn,
              onModeChanged: viewModel.onModeChanged,
              onPowerChanged: viewModel.onPowerChanged,
            ),
            SizedBox(height: 12),
            CardInfoDevices(
              tinacoBateria: viewModel.levelController!.status.tinBattery,
              tinacoSensor: viewModel.levelController!.status.sensorTin,
              tinacoConexion: true,
              cisternaSensor: viewModel.levelController!.status.sensorCis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlSettingPage extends StatelessWidget {
  final ControlDeNivelModelViewModel viewModel;
  const _ControlSettingPage({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    int heightCis = viewModel.levelController!.parameters.heightCis;
    int heightTin = viewModel.levelController!.parameters.heightTin;
    int levelHigh = viewModel.levelController!.parameters.levelHight;
    int levelLow = viewModel.levelController!.parameters.levelLow;
    int minCis = viewModel.levelController!.parameters.minCis;

    return AppScaffold(
      showHeader: true,
      title: 'Control de nivel',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Configuración',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                    color: context.colors.shadow.withValues(alpha: 0.08),
                  ),
                ],
              ),
              child: PanelParametersLc(
                heightCis: heightCis,
                heightTin: heightTin,
                levelHigh: levelHigh,
                levelLow: levelLow,
                minCis: minCis,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
              ),
              onPressed: () => _showEditConfigSheet(context, viewModel),
              icon: Icon(Icons.tune, color: context.colors.surface),
              label: Text(
                'Editar configuración',
                style: TextStyle(color: context.colors.surface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showEditConfigSheet(
  BuildContext context,
  ControlDeNivelModelViewModel viewModel,
) async {
  final parameters = await showModalBottomSheet<ParametersLevelController>(
    backgroundColor: context.colors.surface,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => EditParameterLeveController(
      parameters: viewModel.levelController!.parameters,
    ),
  );

  if (parameters == null) {
    return;
  }

  viewModel.setParameters(parameters);
}
