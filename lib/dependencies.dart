import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:nexus_smart_center/data/repositories/api_repository.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/data/service/api_client.dart';
import 'package:nexus_smart_center/data/service/api_service.dart';
import 'package:nexus_smart_center/data/service/auth_service.dart';
import 'package:nexus_smart_center/data/service/socket_client.dart';
import 'package:nexus_smart_center/domain/session_manager.dart';
import 'package:provider/provider.dart';

class Dependencies extends StatelessWidget {
  const Dependencies({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Servicios Base & HTTP Clients
        Provider(
          create: (_) => SocketClient(serverUrl: 'http://10.0.2.2:5000'),
        ),

        Provider<Dio>(create: (_) => ApiClient.instance.dio),
        Provider(create: (_) => FirebaseAuthService()),
        Provider<ApiService>(
          create: (context) => ApiService(context.read<Dio>()),
        ),

        //  Repositorios
        Provider(
          create: (context) => ApiRepository(
            apiService: context.read(),
            socketClient: context.read(),
          ),
        ),
        Provider(
          create: (context) => AuthRepository(authService: context.read()),
        ),

        // Session / State Manager
        ChangeNotifierProvider<SessionManager>(
          create: (context) => SessionManager(
            authRepository: context.read<AuthRepository>(),
            apiRepository: context.read<ApiRepository>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
