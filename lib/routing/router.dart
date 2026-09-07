import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/domain/session_manager.dart';
import 'package:nexus_smart_center/models/device_model.dart';
import 'package:nexus_smart_center/ui/auth/view_models/login_view_model.dart';
import 'package:nexus_smart_center/ui/auth/view_models/signup_view_model.dart';
import 'package:nexus_smart_center/ui/auth/view_models/verify_email_view_model.dart';
import 'package:nexus_smart_center/ui/auth/views/login_screen.dart';
import 'package:nexus_smart_center/ui/auth/views/signup_screen.dart';
import 'package:nexus_smart_center/ui/auth/views/verify_email_screen.dart';
import 'package:nexus_smart_center/ui/auth/views/welcome_screen.dart';
import 'package:nexus_smart_center/ui/claim/view_models/ble_scan_view_model.dart';
import 'package:nexus_smart_center/ui/claim/view_models/claim_screen_view_model.dart';
import 'package:nexus_smart_center/ui/claim/views/ble_scan_screen.dart';
import 'package:nexus_smart_center/ui/claim/views/claim_screen.dart';
import 'package:nexus_smart_center/ui/core/utils/device_Icon_mapper.dart';
import 'package:nexus_smart_center/ui/core/widgets/app_scaffold.dart';
import 'package:nexus_smart_center/ui/core/widgets/splash_screen.dart';
import 'package:nexus_smart_center/ui/devices/view_models/medidor_view_model.dart';
import 'package:nexus_smart_center/ui/devices/views/medidor_screen.dart';
import 'package:nexus_smart_center/ui/home/view_models/home_view_model.dart';
import 'package:nexus_smart_center/ui/home/views/home_screen.dart';
import 'package:nexus_smart_center/ui/home/views/ver_mas_screen.dart';
import 'package:provider/provider.dart';

abstract final class Routes {
  static const String welcom = '/welcom';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';
  static const String addDevice = '/add_device';
  static const String verMas = '/ver_mas';
  static const String verifyEmail = '/verify_email';
  static const String splash = '/splash';
  static const String scanDevices = '/scan';
  static const String claimDevice = '/claim_device';
  static const String medidor = '/medidor';
  static const shellRoutes = [home, verMas];
  static const publicRoutes = [welcom, signup, login];
}

GoRouter router(SessionManager sessionManager) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  refreshListenable: sessionManager,
  redirect: (context, state) {
    // mejorarar este navegacion de pantallas

    // 1. Aún inicializando/sincronizando -> Mantener en Splash
    if (!sessionManager.isInitialized) {
      return Routes.splash;
    }

    // 2. Si NO está autenticado -> Mandar a Welcome/Login
    if (!sessionManager.isAuthenticated) {
      final isPublic = Routes.publicRoutes.contains(state.matchedLocation);
      return isPublic ? null : Routes.welcom;
    }

    // 3. Email no verificado -> Mandar a Verify Email
    if (!sessionManager.emailVerified) {
      return state.matchedLocation == Routes.verifyEmail
          ? null
          : Routes.verifyEmail;
    }

    // 4. Si YA está autenticado y la ruta actual es Splash, Login/Welcome o VerifyEmail -> Ir a Home
    final isAtSplash = state.matchedLocation == Routes.splash;
    final isAtPublicRoute = Routes.publicRoutes.contains(state.matchedLocation);
    final isAtVerifyEmail = state.matchedLocation == Routes.verifyEmail;

    if (isAtSplash || isAtPublicRoute || isAtVerifyEmail) {
      return Routes.home;
    }

    return null;
  },
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final currentIndex = Routes.shellRoutes.indexOf(state.matchedLocation);
        return AppScaffold(
          body: child,
          showHeader: false,
          showNavigationBar: true,
          currentIndexNavigationBar: currentIndex == -1 ? 0 : currentIndex,
          onTapNavigationBar: (index) {
            context.go(Routes.shellRoutes[index]);
          },
        );
      },
      routes: [
        GoRoute(
          path: Routes.home,
          pageBuilder: (context, state) {
            final viewModel = HomeViewModel(
              authRepository: context.read(),
              apiRepository: context.read(),
            );
            return NoTransitionPage(child: HomeScreen(viewModel: viewModel));
          },
        ),
        GoRoute(
          path: Routes.verMas,
          pageBuilder: (context, state) =>
              NoTransitionPage(child: VerMasScreen()),
        ),
      ],
    ),
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => LoginScreen(
        viewModel: LoginViewModel(authRepository: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) => SignUpScreen(
        viewModel: SignupViewModel(authRepository: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.verifyEmail,
      builder: (context, state) => VerifyEmailScreen(
        viewModel: VerifyEmailViewModel(authRepository: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.welcom,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: Routes.scanDevices,
      builder: (context, state) {
        final viewmodel = BleScanViewModel(bleRepository: context.read());
        viewmodel.startScan();
        return BleScanScreen(viewmodel: viewmodel);
      },
    ),
    GoRoute(
      path: Routes.claimDevice,
      builder: (context, state) {
        final BluetoothDevice deviceId = state.extra as BluetoothDevice;
        final viewModel = ClaimDeviceViewModel(
          bleRepository: context.read(),
          claimRepository: context.read(),
        );
        viewModel.claimDevice(deviceId);
        return ClaimDeviceScreen(viewModel: viewModel);
      },
    ),

    GoRoute(
      path: Routes.medidor,
      builder: ((context, state) {
        final DeviceModel device = state.extra as DeviceModel;

        final viewmodel = MedidorViewModel(
          realTimeRepo: context.read(),
          device: device,
        );
        viewmodel.init(device.id, DeviceIconMapper.getTypeString(device.type));
        return MedidorScreen(viewModel: viewmodel);
      }),
    ),
  ],
);
