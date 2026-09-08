import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/utils/device_Icon_mapper.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/devices/view_models/medidor_view_model.dart';

class MedidorScreen extends StatefulWidget {
  final MedidorViewModel viewModel;

  const MedidorScreen({super.key, required this.viewModel});

  @override
  State<MedidorScreen> createState() => _MedidorScreenState();
}

class _MedidorScreenState extends State<MedidorScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return AppScaffold(
          showHeader: true,
          title: _currentIndex == 0 ? 'Medidor de nivel' : 'Configuración',
          body: IndexedStack(
            index: _currentIndex,
            children: [
              _MedidorHomePage(viewModel: widget.viewModel),
              _MedidorSettingsPage(viewModel: widget.viewModel),
            ],
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
    final percent = viewModel.percent;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Nivel actual',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
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
                    icon: Icons.height,
                    title: 'Altura',
                    value: '${viewModel.height} cm',
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
                viewModel.stateSensor
                    ? Icons.check_circle
                    : Icons.warning_rounded,
                color: viewModel.stateSensor
                    ? context.colors.primary
                    : context.colors.error,
              ),
              title: Text(
                'Estado de sensor :',
                style: context.textTheme.titleSmall,
              ),
              subtitle: Text(
                viewModel.stateSensor
                    ? 'El sensor funciona correctamente.'
                    : 'El sensor reporta fallas en la lectura.',
              ),
            ),
          ),
        ],
      ),
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

    await viewModel.updateConfiguration(
      deviceId: viewModel.device.id,
      type: DeviceIconMapper.getTypeString(viewModel.device.type).toLowerCase(),
      height: height,
      levelHigh: levelHigh,
      levelLow: levelLow,
      alert: viewModel.alert,
    );

    if (!context.mounted) return;

    if (viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(viewModel.errorMessage!)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
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
                  value: viewModel.alert,
                  onChanged: viewModel.isSaving ? null : viewModel.setAlert,
                  title: const Text('Alertas de nivel'),
                  subtitle: const Text(
                    'Recibir una notificación en los niveles configurados',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
