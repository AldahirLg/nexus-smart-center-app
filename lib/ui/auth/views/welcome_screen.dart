import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/nexus_font/nexus_font_icons.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/unen_font/unen_font_icons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppScaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.primary.withValues(alpha: 0.18),
                    colors.primary.withValues(alpha: 0.06),
                  ],
                ),
              ),
              child: Icon(Icons.wifi, size: 60, color: colors.primary),
            ),
            SizedBox(height: 24),
            Center(
              child: Text(
                textAlign: TextAlign.center,
                'Bienvenido',
                style: context.textTheme.headlineLarge?.copyWith(),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  backgroundColor: context.colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  context.push(Routes.login);
                },
                child: Text(
                  'Iniciar Sesion',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: context.colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  context.push(Routes.signup);
                },
                child: Text(
                  'Crear Cuenta',
                  style: context.textTheme.titleMedium?.copyWith(
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
