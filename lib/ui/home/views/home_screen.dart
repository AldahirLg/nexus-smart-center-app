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
                            elevation: 1,
                            shadowColor: context.colors.shadow,
                            color: context.colors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 150,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: context.colors.secondary
                                                    .withValues(alpha: .3),
                                              ),
                                              child: Icon(
                                                Icons.hub,
                                                color: context.colors.secondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          device.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: context.textTheme.bodySmall,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          device.type,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: context.textTheme.bodySmall
                                              ?.copyWith(
                                                color: context.colors.surface,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
