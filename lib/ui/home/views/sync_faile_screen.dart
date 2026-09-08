import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/home/view_models/sync_failed_view_model.dart';

class SyncFaileScreen extends StatelessWidget {
  final SyncFailedViewModel viewModel;
  const SyncFaileScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(viewModel.errorMessaga!),
                SizedBox(height: 8),
                viewModel.isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: viewModel.reIntent,
                        child: Text('Intentar de nuevo'),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
