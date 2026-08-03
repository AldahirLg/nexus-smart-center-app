import 'package:go_router/go_router.dart';
import 'package:nexus_smart_center/data/repositories/auth_repository.dart';
import 'package:nexus_smart_center/ui/auth/view_models/login_view_model.dart';
import 'package:nexus_smart_center/ui/auth/view_models/signup_view_model.dart';
import 'package:nexus_smart_center/ui/auth/view_models/verify_email_view_model.dart';
import 'package:nexus_smart_center/ui/auth/views/signup_screen.dart';
import 'package:nexus_smart_center/ui/auth/views/verify_email_screen.dart';
import 'package:nexus_smart_center/ui/auth/views/welcome_screen.dart';
import 'package:nexus_smart_center/ui/core/widgets/splash_screen.dart';
import 'package:nexus_smart_center/ui/home/view_models/home_view_model.dart';
import 'package:nexus_smart_center/ui/home/views/home_screen.dart';
import 'package:provider/provider.dart';

import '../ui/auth/views/login_screen.dart';

abstract final class Routes {
  static const String welcom = '/welcom';
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';
  static const String verifyEmail = '/verify_email';
  static const String splash = '/splash';
  static const publicRoutes = [welcom, signup, login];
}

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  refreshListenable: authRepository,
  redirect: (context, state) {
    final isAuthenticated = authRepository.isAuthenticated;
    final verified = authRepository.emailVerified;
    final isInitialiazed = authRepository.isInitialiazed;
    final location = state.matchedLocation;

    final isPublicRoute = Routes.publicRoutes.contains(location);

    if (!isInitialiazed) {
      return Routes.splash;
    }

    // Usuario no logueado
    if (!isAuthenticated) {
      if (isPublicRoute) {
        return null;
      }

      return Routes.welcom;
    }

    // Usuario logueado pero correo no verificado
    if (isAuthenticated && !verified) {
      if (location != Routes.verifyEmail) {
        return Routes.verifyEmail;
      }

      return null;
    }

    // Usuario logueado y correo verificado
    if (isAuthenticated && verified) {
      if (isPublicRoute || location == Routes.verifyEmail) {
        return Routes.home;
      }

      return null;
    }

    return null;
  },
  routes: [
    GoRoute(path: Routes.splash, builder: (context, state) => SplashScreen()),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => LoginScreen(
        viewModel: LoginViewModel(authRepository: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) =>
          HomeScreen(viewModel: HomeViewModel(authRepository: context.read())),
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) => SignUpScreen(
        viewModel: SignupViewModel(authRepository: authRepository),
      ),
    ),
    GoRoute(
      path: Routes.verifyEmail,
      builder: (context, state) => VerifyEmailScreen(
        viewModel: VerifyEmailViewModel(authRepository: authRepository),
      ),
    ),
    GoRoute(path: Routes.welcom, builder: (context, state) => WelcomeScreen()),
  ],
);
