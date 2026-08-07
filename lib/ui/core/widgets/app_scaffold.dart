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
          : Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.bottomRight,
                  colors: [context.colors.primary, context.colors.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: NavigationBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  selectedIndex: currentIndexNavigationBar!,
                  onDestinationSelected: onTapNavigationBar,
                  indicatorColor: Colors.transparent,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                    states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return TextStyle(
                        color: context.colors.surface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      );
                    }
                    return TextStyle(
                      color: context.colors.surface.withAlpha(100),
                      fontSize: 12,
                    );
                  }),
                  destinations: [
                    NavigationDestination(
                      icon: Icon(
                        Icons.home_outlined,
                        color: context.colors.surface.withAlpha(100),
                      ),
                      selectedIcon: Icon(
                        Icons.home,
                        color: context.colors.surface,
                      ),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.more_outlined,
                        color: context.colors.surface.withAlpha(100),
                      ),
                      selectedIcon: Icon(
                        Icons.more,
                        color: context.colors.surface,
                      ),
                      label: 'Ver Mas',
                    ),
                  ],
                ),
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.colors.secondary.withValues(alpha: .2),
                      context.colors.secondary.withValues(alpha: .6),
                    ],
                  ),
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

            Positioned(
              bottom: -100,
              left: -80,
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
