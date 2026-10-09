import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/user/widgets/panel_content.dart';

class ChangeNameUserScreen extends StatelessWidget {
  const ChangeNameUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppScaffold(
      showHeader: true,
      title: 'Editar Perfil',
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PanelButtonsPerfil(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentGeometry.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Nombre',
                          style: context.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 12),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Nombre',
                        hintStyle: TextStyle(color: Colors.black, fontSize: 16),
                        filled: true,
                        fillColor: context.colors.secondary,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.secondary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Guardar',
                style: TextStyle(color: context.colors.surface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
