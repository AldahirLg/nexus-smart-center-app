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
          Expanded(
            flex: 5,
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, state) {
                return viewModel.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              mainAxisExtent: 160,
                            ),
                        itemCount: viewModel.devices.length,
                        itemBuilder: (context, index) {
                          final device = viewModel.devices[index];

                          return Card(
                            elevation: 2,
                            shadowColor: context.colors.shadow,
                            color: context.colors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    context.colors.secondary.withValues(
                                      alpha: .8,
                                    ),
                                    context.colors.secondary.withValues(
                                      alpha: .4,
                                    ),
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,

                                        color: context.colors.surface,
                                      ),
                                      width: 50,
                                      height: 50,
                                      child: Icon(
                                        Icons.devices,
                                        size: 30,
                                        color: context.colors.secondary,
                                      ),
                                    ),

                                    const Spacer(),

                                    Text(
                                      device.name,
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: context.colors.surface,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      device.type,
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
              },
            ),
          ),
        ],
      ),
      showHeader: false,
    );
  }
}
