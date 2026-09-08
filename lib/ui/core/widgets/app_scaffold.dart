import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.showHeader = false,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showHeader
          ? AppBar(
              foregroundColor: Colors.black,
              title: Text(title!, style: context.textTheme.titleMedium),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              actions: actions,
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: context.colors.surface),
              ),
            ),
            body,
          ],
        ),
      ),
    );
  }
}
