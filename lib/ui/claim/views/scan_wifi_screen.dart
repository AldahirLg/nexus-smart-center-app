import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/claim/view_models/scan_wifi_view_model.dart';
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
    widget.viewModel.startScanWiFi();
    widget.viewModel.listenResult();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(body: Column());
  }
}
