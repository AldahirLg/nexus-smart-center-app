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
            SizedBox(height: 12),
            FilledButton.tonalIcon(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: context.colors.surface,
              ),
              onPressed: () {
                viewModel.getMedidores();
                _showListMedidores(context, viewModel);
              },
              icon: Icon(Icons.tune, color: context.colors.primary),
              label: Text(
                'Seleccionar medidor de tinaco',
                style: TextStyle(color: context.colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showListMedidores(
  BuildContext context,
  ControlDeNivelModelViewModel viewModel,
) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: context.colors.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          return SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.6,
            child: Column(
              children: [
                // Indicador superior
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.outlineVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.water_drop_outlined,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Seleccionar medidor',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Selecciona el medidor para este dispositivo',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                Expanded(child: _buildMedidoresContent(context, viewModel)),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildMedidoresContent(
  BuildContext context,
  ControlDeNivelModelViewModel viewModel,
) {
  if (viewModel.gettingMedidores) {
    return const Center(child: CircularProgressIndicator());
  }

  if (viewModel.errorGettingMedidores != null) {
    return _MedidoresState(
      icon: Icons.error_outline,
      title: 'No se pudieron obtener los medidores',
      message: 'Ocurrió un error al consultar tus medidores.',
      action: TextButton(
        onPressed: viewModel.getMedidores,
        child: const Text('Reintentar'),
      ),
    );
  }

  final medidores = viewModel.medidores;

  if (medidores == null) {
    return _MedidoresState(
      icon: Icons.water_drop_outlined,
      title: 'No hay información',
      message: 'Todavía no se han cargado los medidores.',
    );
  }

  if (medidores.isEmpty) {
    return _MedidoresState(
      icon: Icons.water_drop_outlined,
      title: 'No hay medidores',
      message: 'No tienes medidores disponibles para seleccionar.',
    );
  }

  // 5. Hay medidores
  return ListView.separated(
    padding: const EdgeInsets.all(16),
    itemCount: medidores.length,
    separatorBuilder: (_, __) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final medidor = medidores[index];

      return Material(
        color: context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop_outlined,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medidor.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.colors.outline),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _MedidoresState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _MedidoresState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 52, color: context.colors.outline),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (action != null) ...[const SizedBox(height: 12), action!],
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
