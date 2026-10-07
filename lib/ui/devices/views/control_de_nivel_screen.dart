import 'package:flutter/material.dart';
import 'package:nexus_smart_center/models/level_controller_model.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/devices/view_models/control_de_nivel_model_view.dart';
import 'package:nexus_smart_center/ui/devices/widgets/bomba_card.dart';
import 'package:nexus_smart_center/ui/devices/widgets/cisterna_card.dart';
import 'package:nexus_smart_center/ui/devices/widgets/edit_parameters_LC.dart';
import 'package:nexus_smart_center/ui/devices/widgets/panel_parameters_LC.dart';
import 'package:nexus_smart_center/ui/devices/widgets/parameters_card.dart';
import 'package:nexus_smart_center/ui/devices/widgets/tinaco_card.dart';
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
        return AppScaffold(
          showHeader: true,
          title: viewModel.device.name,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return AppScaffold(
        showHeader: true,
        title: viewModel.device.name,
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
            TinacoCard(
              level: viewModel.levelController!.status.tinLevel,
              sensor: viewModel.levelController!.status.sensorTin,
              connection: viewModel.levelController!.status.connectionTin,
              battery: viewModel.levelController!.status.tinBattery,
            ),
            SizedBox(height: 12),
            CisternaCard(
              level: viewModel.levelController!.status.cisLevel,
              sensorOk: viewModel.levelController!.status.sensorCis,
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
    final p = viewModel.levelController!.parameters;

    return AppScaffold(
      showHeader: true,
      title: 'Control de nivel',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ParametersCard(
              title: 'Parametros',
              icon: Icons.tune,
              items: [
                ParameterItem(
                  icon: Icons.height,
                  label: 'Altura cisterna',
                  value: '${p.heightCis} cm',
                ),
                ParameterItem(
                  icon: Icons.height,
                  label: 'Altura tinaco',
                  value: '${p.heightTin} cm',
                ),
                ParameterItem(
                  icon: Icons.vertical_align_top,
                  label: 'Nivel alto tinaco',
                  value: '${p.levelHight} %',
                ),
                ParameterItem(
                  icon: Icons.vertical_align_bottom,
                  label: 'Nivel bajo tinaco',
                  value: '${p.levelLow} %',
                ),
                ParameterItem(
                  icon: Icons.warning_amber_rounded,
                  label: 'Mínimo cisterna',
                  value: '${p.minCis} %',
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _showEditConfigSheet(context, viewModel),
              label: const Text(
                'Editar Parametros',
                style: TextStyle(fontWeight: FontWeight.w700),
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
