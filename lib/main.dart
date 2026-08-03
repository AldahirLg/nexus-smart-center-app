import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/dependencies.dart';
import 'package:nexus_smart_center/routing/router.dart';
import 'package:nexus_smart_center/ui/core/themes/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    Dependencies(
      child: Builder(
        builder: (context) {
          return MyApp(router: router(context.read<AuthRepository>()));
        },
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
