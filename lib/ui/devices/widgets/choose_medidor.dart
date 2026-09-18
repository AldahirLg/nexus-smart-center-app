import 'package:flutter/material.dart';
import 'package:nexus_smart_center/models/level_controller_model.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class ChooseMedidor extends StatefulWidget {
  const ChooseMedidor({super.key});

  @override
  State<ChooseMedidor> createState() => _EditParameterLeveControllerState();
}

class _EditParameterLeveControllerState extends State<ChooseMedidor> {
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
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(),
    );
  }
}
