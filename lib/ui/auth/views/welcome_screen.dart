import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/nexus_font/nexus_font_icons.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 24),
            Center(
              child: Text(
                textAlign: TextAlign.center,
                'Welcom Nexus Smart Center',
                style: context.textTheme.headlineLarge?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ),
            Icon(NexusFont.nexusLogo, color: context.colors.primary, size: 150),
            SizedBox(height: 24),
            SizedBox(
              height: 60,
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(),
                onPressed: () {
                  context.push(Routes.login);
                },
                child: Text('Iniciar Sesion'),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 60,
              width: 300,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                ),
                onPressed: () {
                  context.push(Routes.signup);
                },
                child: Text(
                  'Crear Cuenta',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.surface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      showHeader: false,
    );
  }
}
