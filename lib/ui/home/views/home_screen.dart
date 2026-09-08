import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/nexus_font/nexus_font_icons.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/route_observer.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/home/view_models/home_view_model.dart';
import 'package:nexus_smart_center/ui/home/widgets/device_card.dart';
import 'package:nexus_smart_center/unen_font/unen_font_icons.dart';

class HomeScreen extends StatefulWidget {
  final HomeViewModel viewModel;
  const HomeScreen({super.key, required this.viewModel});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    widget.viewModel.initialize();
  }

  @override
  void didPopNext() {
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        UnenFont.unenicon,
                        color: context.colors.surface,
                        size: 40,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'UNEN SMART CENTER ${widget.viewModel.currentUser?.email ?? ""}',
                      style: context.textTheme.headlineMedium,
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Divider(height: 5, color: context.colors.secondary),

                ListenableBuilder(
                  listenable: widget.viewModel,
                  builder: (context, child) {
                    return Center(
                      child: (Text(
                        widget.viewModel.devices.isEmpty
                            ? 'No cuentas con ningun dispositivo'
                            : 'Actualmente tienes ${widget.viewModel.devices.length} dispositivos',
                      )),
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
            listenable: widget.viewModel,
            builder: (context, state) {
              if (widget.viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: widget.viewModel.devices.length,
                itemBuilder: (context, index) {
                  final device = widget.viewModel.devices[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DeviceCard(
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
                    ),
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
