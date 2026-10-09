import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/user/widgets/option_tile.dart';
import 'package:nexus_smart_center/ui/user/widgets/panel_content.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppScaffold(
      showHeader: true,
      title: 'Perfil',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.person_outline,
                  size: 28,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text('Nombre', style: context.textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('correo@ejemplo.com', style: context.textTheme.bodySmall),
              const SizedBox(height: 24),
              Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'DATOS PERSONALES',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              PanelButtonsPerfil(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    OptionTilePerfil(
                      icon: Icons.edit,
                      label: 'Cambiar nombre',
                      onTap: () {
                        context.push(Routes.changeNameUser);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'SEGURIDAD',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              PanelButtonsPerfil(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    OptionTilePerfil(
                      icon: Icons.lock,
                      label: 'Cambiar contraseña',
                      onTap: () {
                        context.push(Routes.updatePasswordUser);
                      },
                    ),
                    const _TileDivider(),
                    OptionTilePerfil(
                      icon: Icons.smartphone,
                      label: 'Sesiones',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: AlignmentGeometry.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'ZONA DE RIESGO',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              PanelButtonsPerfil(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    OptionTilePerfil(
                      icon: Icons.delete,
                      label: 'Eliminar cuenta',
                      onTap: () {},
                      color: Colors.red,
                    ),
                    const _TileDivider(),
                    OptionTilePerfil(
                      icon: Icons.close,
                      label: 'Cerrar sesion',
                      onTap: () {},
                      color: context.colors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 14,
      color: context.colors.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
