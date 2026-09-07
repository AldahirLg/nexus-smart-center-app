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
                      heightFactor: .8,
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
                    value: '${viewModel.height.toInt()} cm',
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
                    ? Icons.warning_rounded
                    : Icons.check_circle,
                color: viewModel.stateSensor
                    ? context.colors.error
                    : context.colors.primary,
              ),
              title: Text(
                'Estado de sensor :',
                style: context.textTheme.titleSmall,
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
        Icon(icon, size: 26, color: context.colors.primary),

        const SizedBox(width: 16),

        Expanded(child: Text(title, style: context.textTheme.bodyMedium)),

        Text(value, style: context.textTheme.bodyMedium),
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
            decoration: InputDecoration(
              labelStyle: context.textTheme.bodyMedium,
              labelText: 'Altura del contenedor',
              suffixText: 'cm',
              prefixIcon: Icon(Icons.height, color: context.colors.primary),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.secondary),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.colors.secondary,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _levelHighController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelStyle: context.textTheme.bodyMedium,
              labelText: 'Nivel alto',
              suffixText: 'cm',
              prefixIcon: Icon(
                Icons.notifications,
                color: context.colors.primary,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.secondary),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.colors.secondary,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          TextFormField(
            controller: _levelLowController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelStyle: context.textTheme.bodyLarge,
              labelText: 'Nivel bajo',
              suffixText: 'cm',
              prefixIcon: Icon(
                Icons.notifications,
                color: context.colors.primary,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colors.secondary),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.colors.secondary,
                  width: 2,
                ),
              ),
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

              onPressed: viewModel.isSaving ? null : _saveConfiguration,

              child: viewModel.isSaving
                  ? CircularProgressIndicator()
                  : Text(
                      'Guardar Informacion',
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
