import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/home/view_models/home_view_model.dart';
import 'package:nexus_smart_center/ui/home/widgets/device_card.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;
  const HomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
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

                        return DeviceCard(
                          device: device,
                          onTap: () {
                            context.push(
                              Routes.medidor,
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
