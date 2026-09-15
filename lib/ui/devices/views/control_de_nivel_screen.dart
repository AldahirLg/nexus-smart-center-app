import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/devices/view_models/control_de_nivel_model_view.dart';
import 'package:nexus_smart_center/ui/devices/widgets/bomba_card.dart';
import 'package:nexus_smart_center/ui/devices/widgets/card_container.dart';
import 'package:nexus_smart_center/ui/devices/widgets/card_info_devices.dart';
import 'package:nexus_smart_center/ui/devices/widgets/control_config_field.dart';

class ControlDeNivelScreen extends StatefulWidget {
  final ControlDeNivelModelViewModel viewModel;
  const ControlDeNivelScreen({super.key, required this.viewModel});
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _ControlHomePage(viewModel: widget.viewModel),
          _ControlSettingPage(viewModel: widget.viewModel),
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
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return AppScaffold(
          showHeader: true,
          title: 'Control de Nivel',
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CardContainer(percent: 100, title: 'Tinaco'),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: CardContainer(percent: 50, title: 'Cisterna'),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                BombaCard(
                  mode: BombaMode.manual,
                  isOn: true,
                  onModeChanged: (BombaMode mode) {},
                  onPowerChanged: (bool value) {},
                ),
                SizedBox(height: 12),
                CardInfoDevices(onTapCisterna: () {}, onTapTinaco: () {}),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ControlSettingPage extends StatelessWidget {
  final ControlDeNivelModelViewModel viewModel;
  const _ControlSettingPage({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
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
                  child: const Column(
                    children: [
                      _ConfigValueTile(label: 'Altura cisterna', value: 100),
                      _ConfigDivider(),
                      _ConfigValueTile(label: 'Altura tinaco', value: 100),
                      _ConfigDivider(),
                      _ConfigValueTile(label: 'Nivel alto', value: 80),
                      _ConfigDivider(),
                      _ConfigValueTile(label: 'Nivel bajo', value: 40),
                      _ConfigDivider(),
                      _ConfigValueTile(label: 'Mínimo cisterna', value: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonalIcon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                  ),
                  onPressed: () => _showEditConfigSheet(context),
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
      },
    );
  }
}

class _ConfigValueTile extends StatelessWidget {
  final String label;
  final int value;

  const _ConfigValueTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Text('$value cm', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ConfigDivider extends StatelessWidget {
  const _ConfigDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: context.colors.outlineVariant,
    );
  }
}

void _showEditConfigSheet(BuildContext context) {
  showModalBottomSheet(
    backgroundColor: context.colors.surface,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => const _EditConfigSheet(),
  );
}

class _EditConfigSheet extends StatelessWidget {
  const _EditConfigSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Editar configuración',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          ConfigField(label: 'Altura cisterna (cm)', initialValue: '100'),
          const SizedBox(height: 12),
          ConfigField(label: 'Altura tinaco (cm)', initialValue: '100'),
          const SizedBox(height: 12),
          ConfigField(label: 'Nivel alto (%)', initialValue: '80'),
          const SizedBox(height: 12),
          ConfigField(label: 'Nivel bajo (%)', initialValue: '40'),
          const SizedBox(height: 12),
          ConfigField(label: 'Mínimo cisterna (%)', initialValue: '20'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
