import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/view_models/logout_view_model.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/core/widgets/logout_button.dart';
import 'package:nexus_smart_center/ui/home/view_models/home_view_model.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final HomeViewModel viewModel;
  const HomeScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inicio',
      actions: [],
      body: Column(
        children: [
          LogoutButton(
            viewModel: LogoutViewModel(authRepository: context.read()),
          ),
          Center(
            child: Text(
              'Bienvenido ${viewModel.currentUser?.email ?? ""}',
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      showHeader: false,
    );
  }
}
