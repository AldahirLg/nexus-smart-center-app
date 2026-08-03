import 'package:flutter/material.dart';
import 'package:nexus_smart_center/nexus_font/nexus_font_icons.dart';
import 'package:nexus_smart_center/ui/auth/view_models/signup_view_model.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';

class SignUpScreen extends StatelessWidget {
  final SignupViewModel viewModel;

  const SignUpScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Crear Cuenta',
      showHeader: true,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Icon(
              NexusFont.nexusLogo,
              size: 140,
              color: context.colors.primary,
            ),
          ),

          Expanded(
            flex: 5,
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 24,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                        ),
                        child: Form(
                          key: viewModel.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                style: TextStyle(color: context.colors.primary),
                                cursorErrorColor: context.colors.error,
                                cursorColor: context.colors.primary,
                                controller: viewModel.emailController,
                                validator: viewModel.validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'E-mail',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                style: TextStyle(color: context.colors.primary),
                                cursorErrorColor: context.colors.error,
                                cursorColor: context.colors.primary,
                                controller: viewModel.passwordController,
                                validator: viewModel.validatePassword,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    side: BorderSide(
                                      color: viewModel.showTermsError
                                          ? context.colors.error
                                          : context.colors.primary,
                                      width: 2,
                                    ),
                                    value: viewModel.termsAndConditions,
                                    onChanged: (value) => viewModel
                                        .checkTermsAndConditions(value!),
                                  ),
                                  Expanded(
                                    child: Text(
                                      textAlign: TextAlign.center,
                                      'Acepto los Términos y Condiciones y la Política de Privacidad.',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: viewModel.showTermsError
                                                ? context.colors.error
                                                : context.colors.primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (viewModel.showTermsError)
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text(
                                    'Debes aceptar los términos y condiciones.',
                                    style: TextStyle(
                                      color: context.colors.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              if (viewModel.isLoading)
                                Center(child: CircularProgressIndicator())
                              else
                                SizedBox(
                                  height: 60,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.colors.primary,
                                    ),
                                    onPressed: () {
                                      viewModel.submit();
                                    },
                                    child: Text(
                                      'Continuar',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: context.colors.surface,
                                          ),
                                    ),
                                  ),
                                ),
                              if (viewModel.errorMessage != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  viewModel.errorMessage!,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.error,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: context.colors.primary,
                                      thickness: 2,
                                    ),
                                  ),
                                  Text(' or '),
                                  Expanded(
                                    child: Divider(
                                      color: context.colors.primary,
                                      thickness: 2,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton.filled(
                                    iconSize: 40,
                                    alignment: AlignmentDirectional.centerStart,
                                    onPressed: () {},
                                    icon: Icon(Icons.facebook),
                                  ),
                                  SizedBox(width: 16),
                                  IconButton.filled(
                                    iconSize: 40,
                                    alignment: AlignmentDirectional.centerStart,
                                    onPressed: () {},
                                    icon: Icon(Icons.apple),
                                  ),
                                  SizedBox(width: 16),
                                  IconButton.filled(
                                    iconSize: 40,
                                    alignment: AlignmentDirectional.centerStart,
                                    onPressed: () {},
                                    icon: Icon(Icons.mail),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Registrate con tu red social favorita',
                                    style: context.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
