import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/view_models/logout_view_model.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key, required this.viewModel});
  final LogoutViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return IconButton(
          icon: viewModel.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.logout),
          onPressed: viewModel.isLoading
              ? null
              : () {
                  viewModel.logout();
                },
        );
      },
    );
  }
}
