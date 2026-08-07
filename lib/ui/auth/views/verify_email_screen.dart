import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/auth/view_models/verify_email_view_model.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/view_models/logout_view_model.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/core/widgets/logout_button.dart';
import 'package:provider/provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  final VerifyEmailViewModel viewModel;
  const VerifyEmailScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showNavigationBar: false,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Icon(
              Icons.gamepad,
              size: 100,
              color: context.colors.primary,
            ),
          ),
          Expanded(
            flex: 5,
            child: SizedBox(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      'Verifica tu correo electronico',
                      style: context.textTheme.headlineMedium?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      textAlign: TextAlign.center,
                      'Hemos enviado una link de verificacion a tu correo revisa la bandeja de entrada, despues de la confirmacion presiona el siguiente boton:',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: viewModel.isLoading
                          ? CircularProgressIndicator()
                          : SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  viewModel.checkEmailVerification();
                                },
                                child: Text('Confirmar'),
                              ),
                            ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      child: LogoutButton(
                        viewModel: LogoutViewModel(
                          authRepository: context.read(),
                        ),
                      ),
                    ),
                    if (viewModel.errorMessage != null)
                      Text(
                        viewModel.errorMessage!,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colors.error,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      showHeader: true,
      title: 'Verificacion de correo',
    );
  }
}
