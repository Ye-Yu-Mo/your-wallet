import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_account_screen.dart';
import 'router_singleton.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'splash',
      pageBuilder: (context, state) => const MaterialPage(child: SplashScreen()),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => const MaterialPage(child: RegisterScreen()),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => const MaterialPage(child: HomeScreen()),
    ),
    GoRoute(
      path: '/add-account',
      name: 'add-account',
      pageBuilder: (context, state) => const MaterialPage(child: AddAccountScreen()),
    ),
  ],
);

// expose globally for non-UI layers (e.g., providers)
// ignore: unnecessary_statements
void _initGlobalRouter() { globalRouter = appRouter; }
final _ = _initGlobalRouter();
