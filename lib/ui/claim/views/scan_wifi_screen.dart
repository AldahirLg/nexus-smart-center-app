import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/claim/view_models/scan_wifi_view_model.dart';
import 'package:nexus_smart_center/ui/claim/widgets/save_network_card.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';

class ScanWifiScreen extends StatefulWidget {
  final ScanWifiViewModel viewModel;

  const ScanWifiScreen({super.key, required this.viewModel});

  @override
  State<ScanWifiScreen> createState() => _ScanWifiScreenState();
}

class _ScanWifiScreenState extends State<ScanWifiScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.startScanWiFi();
    widget.viewModel.listenResult();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Selecciona tu red Wi-Fi',
      showHeader: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, child) {
                return widget.viewModel.networkSaved == null
                    ? Text('No tienes WiFi guardado')
                    : Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.colors.secondary,
                          borderRadius: BorderRadius.circular(16),
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
                                      color: context.colors.surface,
                                    ),
                                    child: const Icon(Icons.wifi),
                                  ),
                                  const SizedBox(width: 24),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('WiFi guardado'),
                                      Text(
                                        widget.viewModel.networkSaved!.ssid,
                                        style: context.textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context.colors.surface,
                                    elevation: 4,
                                  ),
                                  onPressed: () {},
                                  child: const Text('Continuar'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
              },
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
                    widget.viewModel.startScanWiFi();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: ListenableBuilder(
              listenable: widget.viewModel,
              builder: (context, child) {
                final networks = widget.viewModel.networks;

                if (networks.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron redes Wi-Fi'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: networks.length,
                  itemBuilder: (context, index) {
                    final network = networks[index];

                    return ListTile(
                      leading: const Icon(Icons.wifi),
                      title: Text(
                        network.ssid.isEmpty ? 'Red sin nombre' : network.ssid,
                      ),
                      subtitle: Text('${network.signal} dBm'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final password = await showWifiPasswordSheet(
                          context,
                          ssid: network.ssid,
                        );

                        if (password == null) return;

                        await widget.viewModel.saveNetwork(
                          network.ssid,
                          password,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
