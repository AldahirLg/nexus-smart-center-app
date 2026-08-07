import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/home/view_models/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;
  const HomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showNavigationBar: false,
      title: 'Inicio',
      actions: [],
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Mis Dispositivos ${viewModel.currentUser?.email ?? ""}',
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    'Presiona sobre las tarjetas para acceder a tus dispositivos',
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: 5, child: Center()),
        ],
      ),
      showHeader: false,
    );
  }
}
