import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/core/widgets/cards_acceso.dart';

class VerMasScreen extends StatelessWidget {
  const VerMasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Accesos Rapidos',
                  style: context.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CardAcceso(
                      color: Colors.deepPurple,
                      icon: Icons.person,
                      title: 'Perfil',
                      bodyText:
                          'Administra las funciones disponibles de tu perfil',
                      onTap: () {},
                    ),
                    Divider(
                      color: context.colors.primary.withValues(alpha: .2),
                      thickness: 2,
                      height: 24,
                    ),
                    CardAcceso(
                      color: Colors.red,
                      icon: Icons.link,
                      title: 'Vicular Dispositivos',
                      bodyText:
                          'Realiza la vinculacion de los dispositivos a tu cuenta',
                      onTap: () {
                        context.push(Routes.addDevice);
                      },
                    ),
                    Divider(
                      color: context.colors.primary.withValues(alpha: .2),
                      thickness: 2,
                      height: 24,
                    ),
                    CardAcceso(
                      icon: Icons.info,
                      title: 'Acerca de',
                      bodyText:
                          'Informacion acerca de tus dispositivos y la aplicacion',
                      color: Colors.amber,
                      onTap: () {},
                    ),
                    Divider(
                      color: context.colors.primary.withValues(alpha: .2),
                      thickness: 2,
                      height: 24,
                    ),
                    CardAcceso(
                      icon: Icons.phone,
                      title: 'Ayuda y soporte',
                      bodyText: 'Encuentra respuestas rapidas o contactanos',
                      color: Colors.indigo,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      showHeader: false,
      showNavigationBar: false,
    );
  }
}
