import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:provider/provider.dart';

class Dependencies extends StatelessWidget {
  const Dependencies({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => FirebaseAuthService()),
        ChangeNotifierProvider(
          create: (context) => AuthRepository(authService: context.read()),
        ),
      ],
      child: child,
    );
  }
}
