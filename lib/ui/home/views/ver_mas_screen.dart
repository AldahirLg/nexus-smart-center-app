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
    return Padding(
      padding: EdgeInsetsGeometry.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('App y Cuenta', style: context.textTheme.titleMedium),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: context.colors.secondary, width: 1),
              ),
              width: double.infinity,
              height: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: context.colors.primary.withValues(alpha: .5),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: context.colors.primary,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Aldahir Lopez',
                        style: context.textTheme.titleMedium,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'correo@example.com',
                        style: context.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  SizedBox(width: 12),
                  TextButton.icon(onPressed: () {}, label: Text('Editar')),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              shape: .rectangle,
              border: Border.all(color: context.colors.secondary, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () {
                context.push(Routes.scanWiFi);
              },
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: .rectangle,
                        borderRadius: BorderRadius.circular(20),
                        color: context.colors.primary.withValues(alpha: .5),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: context.colors.primary,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Agregar dispositivo',
                      style: context.textTheme.titleSmall,
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_right),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
