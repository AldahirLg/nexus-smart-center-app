import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/route_observer.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/utils/device_Icon_mapper.dart';
import 'package:nexus_smart_center/ui/home/view_models/home_view_model.dart';
import 'package:nexus_smart_center/ui/home/widgets/device_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  PageRoute<dynamic>? _subscribedRoute;

  HomeViewModel get viewModel => context.read<HomeViewModel>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);

    if (route is PageRoute<dynamic> && route != _subscribedRoute) {
      if (_subscribedRoute != null) {
        routeObserver.unsubscribe(this);
      }

      _subscribedRoute = route;
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mis Dispositivos',
                  style: context.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, child) {
                    return Text(
                      '${viewModel.devices.length} vinculados a tu cuenta',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 8,
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.messageError != null && viewModel.devices.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          viewModel.messageError!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: viewModel.initialize,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (viewModel.devices.isEmpty) {
                return const Center(
                  child: Text('No tienes dispositivos vinculados.'),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: viewModel.devices.length,
                itemBuilder: (context, index) {
                  final device = viewModel.devices[index];

                  return DeviceCard(
                    device: device,
                    onTap: () {
                      final route = Routes.devicesRoutes.firstWhere(
                        (route) =>
                            route == DeviceIconMapper.getRoute(device.type),
                        orElse: () => '/',
                      );

                      if (route == '/') return;

                      context.push(
                        route,
                        extra: DeviceModel(
                          id: device.id,
                          name: device.name,
                          type: device.type,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
