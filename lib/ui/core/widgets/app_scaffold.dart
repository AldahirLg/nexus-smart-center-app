import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    required this.showHeader,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showHeader
          ? AppBar(title: Text(title!), centerTitle: true)
          : null,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.5),
              ),
            ),
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              children: [Expanded(child: Center(child: body))],
            ),
          ],
        ),
      ),
    );
  }
}
