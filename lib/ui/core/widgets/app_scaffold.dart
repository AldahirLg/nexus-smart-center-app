import 'package:flutter/material.dart';
import 'package:nexus_smart_center/ui/core/themes/context_extensions.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    required this.showHeader,
    required this.showNavigationBar,
    this.currentIndexNavigationBar,
    this.onTapNavigationBar,
  });

  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final bool showHeader;
  final bool showNavigationBar;
  final int? currentIndexNavigationBar;
  final ValueChanged<int>? onTapNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: !showNavigationBar
          ? null
          : SizedBox(
              height: 80,
              child: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined, size: 20),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined, size: 20),
                    activeIcon: Icon(Icons.settings),
                    label: 'Ver más',
                  ),
                ],
                currentIndex: currentIndexNavigationBar!,
                selectedItemColor: context.colors.secondary,
                unselectedItemColor: context.colors.secondary,
                selectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                onTap: onTapNavigationBar,
              ),
            ),
      appBar: showHeader
          ? AppBar(title: Text(title!), centerTitle: true)
          : null,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerLowest,
                ),
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
                  ).colorScheme.primary.withValues(alpha: 0.1),
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
