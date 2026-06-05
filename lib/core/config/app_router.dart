import 'package:go_router/go_router.dart';
import 'package:papirar/features/auth/domain/auth_session_guard.dart';
import 'package:papirar/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:papirar/features/auth/presentation/screens/login_screen.dart';
import 'package:papirar/features/auth/presentation/screens/register_screen.dart';
import 'package:papirar/features/home/home_screen.dart';
import 'package:papirar/features/lei_seca/lei_seca_screen.dart';
import 'package:papirar/features/perfil/perfil_screen.dart';
import 'package:papirar/features/splash/splash_screen.dart';
import 'package:papirar/shared/widgets/app_shell.dart';

// Nomes de rotas — use context.goNamed(AppRoutes.xxx)
class AppRoutes {
  static const splash = 'splash';
  static const login = 'login';
  static const register = 'cadastro';
  static const forgotPassword = 'esqueci-senha';
  static const home = 'home';
  static const leiSeca = 'lei-seca';
  static const perfil = 'perfil';
}

// Caminhos de rota
class AppPaths {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/cadastro';
  static const forgotPassword = '/esqueci-senha';
  static const home = '/';
  static const leiSeca = '/lei-seca';
  static const perfil = '/perfil';
}

final appRouter = GoRouter(
  initialLocation: AppPaths.splash,
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final path = state.uri.path;
    final isPublicRoute =
        path == AppPaths.splash ||
        path == AppPaths.login ||
        path == AppPaths.register ||
        path == AppPaths.forgotPassword;
    final hasSession = AuthSessionGuard.hasActiveSession;

    if (!hasSession && !isPublicRoute) {
      final redirectPath = Uri.encodeComponent(state.uri.toString());
      return '${AppPaths.login}?redirect=$redirectPath';
    }

    if (hasSession && isPublicRoute) {
      return AppPaths.home;
    }

    return null;
  },
  routes: [
    // Splash — fora do shell (sem NavigationBar)
    GoRoute(
      path: AppPaths.splash,
      name: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppPaths.login,
      name: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppPaths.register,
      name: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppPaths.forgotPassword,
      name: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Shell principal com NavigationBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Aba 0 — Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPaths.home,
              name: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        // Aba 1 — Lei Seca
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPaths.leiSeca,
              name: AppRoutes.leiSeca,
              builder: (context, state) => const LeiSecaScreen(),
            ),
          ],
        ),

        // Aba 2 — Perfil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppPaths.perfil,
              name: AppRoutes.perfil,
              builder: (context, state) => const PerfilScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
