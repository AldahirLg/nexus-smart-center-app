import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/models/medidor_model.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/devices/view_models/medidor_view_model.dart';
import 'package:nexus_smart_center/ui/devices/widgets/level_controller_state.dart';
import 'package:provider/provider.dart';

class MedidorScreen extends StatefulWidget {
  const MedidorScreen({super.key});

  @override
  State<MedidorScreen> createState() => _MedidorScreenState();
}

class _MedidorScreenState extends State<MedidorScreen> {
  int _currentIndex = 0;

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MedidorViewModel>();
    final medidor = viewModel.medidor;
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        if (viewModel.isLoading || medidor == null || viewModel.isChangeAuto) {
          return const AppScaffold(
            showHeader: true,
            title: 'Medidor de nivel',
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.medidor!.parameters.mode == "extension") {
          return AppScaffold(
            showHeader: true,
            title: 'Medidor de nivel',
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Este dispositivo esta en moodo Extension"),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      viewModel.changeAutoMode(
                        viewModel.medidor!.parameters.copyWith(
                          mode: 'auto',
                          pointerId: '',
                        ),
                      );
                    },
                    child: viewModel.isChangeAuto
                        ? CircularProgressIndicator()
                        : Text('Camibar a automatico'),
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _MedidorHomePage(viewModel: viewModel),
              _MedidorSettingsPage(viewModel: viewModel),
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
      },
    );
  }
}

class _MedidorHomePage extends StatelessWidget {
  final MedidorViewModel viewModel;

  const _MedidorHomePage({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final medidor = viewModel.medidor;
        final percent = medidor!.status.percent;
        return AppScaffold(
          showHeader: true,
          title: viewModel.device.name,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nivel actual',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 16),

                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: context.colors.surface,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                          color: context.colors.secondary,
                        ),
                      ],
                    ),
                    height: 150,
                    width: 150,
                    padding: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: context.colors.secondary,
                          ),
                          FractionallySizedBox(
                            widthFactor: 1,
                            heightFactor: percent / 100,
                            alignment: Alignment.bottomCenter,
                            child: Container(color: context.colors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.colors.surface,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                        color: context.colors.secondary,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.water,
                          title: 'Nivel',
                          value: '$percent %',
                        ),
                        Divider(height: 24, color: context.colors.secondary),
                        _InfoRow(
                          icon: Icons.battery_full,
                          title: 'Bateria',
                          value: '${medidor.status.battery} cm',
                        ),
                        Divider(height: 24, color: context.colors.secondary),
                        _InfoRow(
                          icon: Icons.height,
                          title: 'Altura',
                          value: '${medidor.parameters.height} cm',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.colors.surface,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                        color: context.colors.secondary,
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Icon(
                      medidor.status.sensorState
                          ? Icons.check_circle
                          : Icons.warning_rounded,
                      color: medidor.status.sensorState
                          ? context.colors.primary
                          : context.colors.error,
                    ),
                    title: Text(
                      'Estado de sensor :',
                      style: context.textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      medidor.status.sensorState
                          ? 'El sensor funciona correctamente.'
                          : 'El sensor reporta fallas en la lectura.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 26, color: context.colors.primary),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: context.textTheme.bodyMedium)),
        Text(value, style: context.textTheme.bodyMedium),
      ],
    );
  }
}

class _MedidorSettingsPage extends StatelessWidget {
  final MedidorViewModel viewModel;

  const _MedidorSettingsPage({required this.viewModel});

  Future<void> _saveConfiguration(BuildContext context) async {
    final height = int.tryParse(viewModel.heightController.text);
    final levelHigh = int.tryParse(viewModel.levelHighController.text);
    final levelLow = int.tryParse(viewModel.levelLowController.text);

    if (height == null || levelHigh == null || levelLow == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa valores válidos.')));
      return;
    }

    if (height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La altura debe ser mayor que 0.')),
      );
      return;
    }

    if (levelHigh > height || levelLow > height) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Los niveles no pueden superar la altura del contenedor.',
          ),
        ),
      );
      return;
    }

    if (levelLow >= levelHigh) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nivel bajo debe ser menor que el nivel alto.'),
        ),
      );
      return;
    }

    final currentAlert = viewModel.medidor?.parameters.alert ?? false;

    if (!context.mounted) return;

    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      return;
    }
    viewModel.setParameters(
      viewModel.medidor!.parameters.copyWith(
        height: height,
        levelHigh: levelHigh,
        levelLow: levelLow,
      ),
    );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        final alert = viewModel.medidor?.parameters.alert ?? false;

        return AppScaffold(
          showHeader: true,
          title: 'Configuración',
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Parámetros del contenedor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Text(
                  'Configura las dimensiones y niveles de alerta.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                TextFormField(
                  controller: viewModel.heightController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    context,
                    label: 'Altura del contenedor',
                    suffix: 'cm',
                    icon: Icons.height,
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: viewModel.levelHighController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    context,
                    label: 'Nivel alto',
                    suffix: 'cm',
                    icon: Icons.notifications,
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: viewModel.levelLowController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    context,
                    label: 'Nivel bajo',
                    suffix: 'cm',
                    icon: Icons.notifications,
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                    ),
                    onPressed: viewModel.isSaving
                        ? null
                        : () => _saveConfiguration(context),
                    child: viewModel.isSaving
                        ? const CircularProgressIndicator()
                        : Text(
                            'Guardar información',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.surface,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                        color: context.colors.secondary,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Material(
                      color: context.colors.surface,
                      child: SwitchListTile(
                        value: alert,
                        onChanged: viewModel.isSaving
                            ? null
                            : viewModel.setAlert,
                        title: const Text('Alertas de nivel'),
                        subtitle: const Text(
                          'Recibir una notificación en los niveles configurados',
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: context.colors.surface,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                        color: context.colors.secondary,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      'Modo: Automático',
                      style: context.textTheme.titleSmall,
                    ),
                    subtitle: const Text(
                      'Presiona el botón para cambiar a modo extensión',
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        viewModel.getMedidores();
                        _listeLevelControllers(context, viewModel);
                      },
                      icon: const Icon(Icons.swap_vert),
                      color: context.colors.primary,
                      tooltip: 'Cambiar modo',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _listeLevelControllers(
    BuildContext context,
    MedidorViewModel viewModel,
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
                            color: context.colors.primary.withValues(
                              alpha: 0.1,
                            ),
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
                                'Seleccionar dispositivo',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Selecciona el controlador de nivel',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: _buildLevelControllerContent(context, viewModel),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLevelControllerContent(
    BuildContext context,
    MedidorViewModel viewModel,
  ) {
    if (viewModel.gettingControllers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.errorGettingControllers != null) {
      return LevelControllerState(
        icon: Icons.error_outline,
        title: 'No se pudieron obtener los medidores',
        message: 'Ocurrió un error al consultar tus medidores.',
        action: TextButton(
          onPressed: viewModel.getMedidores,
          child: const Text('Reintentar'),
        ),
      );
    }

    final medidores = viewModel.controllers;

    if (medidores == null) {
      return LevelControllerState(
        icon: Icons.water_drop_outlined,
        title: 'No hay información',
        message: 'Todavía no se han cargado los dispositivos.',
      );
    }

    if (medidores.isEmpty) {
      return LevelControllerState(
        icon: Icons.water_drop_outlined,
        title: 'No hay dispositivos',
        message: 'No tienes dispostivos disponibles para seleccionar.',
      );
    }

    // 5. Hay controladores
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: medidores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final controller = medidores[index];

        return Material(
          color: context.colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              viewModel.changeAutoMode(
                viewModel.medidor!.parameters.copyWith(
                  mode: 'extension',
                  pointerId: controller.id,
                ),
              );
              Navigator.pop(context);
            },
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
                          controller.name,
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

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      suffixText: suffix,
      prefixIcon: Icon(icon, color: context.colors.primary),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.colors.secondary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.colors.secondary, width: 2),
      ),
    );
  }
}
