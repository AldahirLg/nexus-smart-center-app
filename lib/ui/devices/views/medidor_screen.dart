import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
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

    widget.viewModel.initialize(widget.viewModel.device.id);
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
          showNavigationBar: true,
          title: _currentIndex == 0 ? 'Medidor de nivel' : 'Configuración',
          currentIndexNavigationBar: _currentIndex,
          onTapNavigationBar: _onNavigationTap,
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

          const SizedBox(height: 20),

          Center(
            child: SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 10,
                  ),

                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          Card(
            color: context.colors.surface,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.water_drop_outlined,
                    title: 'Nivel',
                    value: '$percent %',
                  ),

                  const Divider(height: 24),

                  _InfoRow(
                    icon: Icons.height,
                    title: 'Altura',
                    value: '${viewModel.height.toInt()} cm',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            color: context.colors.surface,
            child: ListTile(
              leading: Icon(
                viewModel.stateSensor
                    ? Icons.warning_rounded
                    : Icons.check_circle,
                color: viewModel.stateSensor ? Colors.orange : Colors.green,
              ),
              title: Text(
                viewModel.stateSensor
                    ? 'Estado del sensor: alerta'
                    : 'Estado normal',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                viewModel.stateSensor
                    ? 'El sensor reporta una condición de alerta.'
                    : 'El sensor funciona correctamente.',
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
        Icon(icon, size: 26, color: context.colors.secondary),

        const SizedBox(width: 16),

        Expanded(child: Text(title, style: const TextStyle(fontSize: 15))),

        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _MedidorSettingsPage extends StatefulWidget {
  final MedidorViewModel viewModel;

  const _MedidorSettingsPage({required this.viewModel});

  @override
  State<_MedidorSettingsPage> createState() => _MedidorSettingsPageState();
}

class _MedidorSettingsPageState extends State<_MedidorSettingsPage> {
  late final TextEditingController _heightController;
  late final TextEditingController _levelHighController;
  late final TextEditingController _levelLowController;

  bool _alert = false;

  @override
  void initState() {
    super.initState();

    final viewModel = widget.viewModel;

    _heightController = TextEditingController(
      text: viewModel.height > 0 ? viewModel.height.toInt().toString() : '',
    );

    _levelHighController = TextEditingController(
      text: viewModel.levelHigh > 0
          ? viewModel.levelHigh.toInt().toString()
          : '',
    );

    _levelLowController = TextEditingController(
      text: viewModel.levelLow > 0 ? viewModel.levelLow.toInt().toString() : '',
    );

    _alert = viewModel.alert;
  }

  @override
  void dispose() {
    _heightController.dispose();
    _levelHighController.dispose();
    _levelLowController.dispose();

    super.dispose();
  }

  Future<void> _saveConfiguration() async {
    final height = double.tryParse(_heightController.text);
    final levelHigh = double.tryParse(_levelHighController.text);
    final levelLow = double.tryParse(_levelLowController.text);

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

    await widget.viewModel.updateConfiguration(
      deviceId: widget.viewModel.device.id,
      height: height,
      levelHigh: levelHigh,
      levelLow: levelLow,
      alert: _alert,
    );

    if (!mounted) return;

    if (widget.viewModel.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(widget.viewModel.errorMessage!)));

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuración guardada correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

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
            controller: _heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Altura del contenedor',
              suffixText: 'cm',
              prefixIcon: Icon(Icons.height),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _levelHighController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Nivel alto',
              suffixText: 'cm',
              prefixIcon: Icon(Icons.arrow_upward),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _levelLowController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Nivel bajo',
              suffixText: 'cm',
              prefixIcon: Icon(Icons.arrow_downward),
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 30),

          FilledButton.icon(
            onPressed: viewModel.isSaving ? null : _saveConfiguration,
            icon: viewModel.isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              viewModel.isSaving ? 'Guardando...' : 'Guardar configuración',
            ),
          ),

          const SizedBox(height: 30),

          Card(
            child: SwitchListTile(
              value: _alert,
              onChanged: viewModel.isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _alert = value;
                      });
                    },
              title: const Text('Alertas de nivel'),
              subtitle: const Text(
                'Recibir una notificación en los niveles configurados',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
