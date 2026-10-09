import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/claim/view_models/scan_wifi_view_model.dart';
import 'package:nexus_smart_center/ui/claim/widgets/save_network_card.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:provider/provider.dart';

class ScanWifiScreen extends StatefulWidget {
  const ScanWifiScreen({super.key});

  @override
  State<ScanWifiScreen> createState() => _ScanWifiScreenState();
}

class _ScanWifiScreenState extends State<ScanWifiScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ScanWifiViewModel>();
    final colors = context.colors;

    return AppScaffold(
      title: 'Selecciona tu red Wi-Fi',
      showHeader: true,
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          final networks = viewModel.networks;

          return Column(
            children: [
              if (viewModel.networkSaved != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                          color: colors.shadow.withValues(alpha: 0.06),
                        ),
                      ],
                      color: context.colors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: context.colors.secondary,
                                ),
                                child: const Icon(Icons.wifi),
                              ),
                              const SizedBox(width: 24),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('WiFi guardado'),
                                  Text(
                                    viewModel.networkSaved!.ssid,
                                    style: context.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.primary,
                                elevation: 4,
                              ),
                              onPressed: () {
                                context.push(Routes.scanDevices);
                              },
                              child: Text(
                                'Continuar',
                                style: TextStyle(color: context.colors.surface),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 14),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Selecciona tu WiFi'),
                    IconButton(
                      icon: const Icon(Icons.update),
                      onPressed: () {
                        viewModel.startScanWiFi();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: networks.isEmpty
                    ? const Center(child: Text('No se encontraron redes Wi-Fi'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: networks.length,
                        itemBuilder: (context, index) {
                          final network = networks[index];
                          return ListTile(
                            leading: const Icon(Icons.wifi),
                            title: Text(
                              network.ssid.isEmpty
                                  ? 'Red sin nombre'
                                  : network.ssid,
                            ),
                            subtitle: Text('${network.signal} dBm'),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              final password = await showWifiPasswordSheet(
                                context,
                                ssid: network.ssid,
                              );

                              if (password == null) return;

                              await viewModel.saveNetwork(
                                network.ssid,
                                password,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
