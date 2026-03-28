import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import 'app_shell.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AppShell(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class AkwabaPayApp extends StatelessWidget {
  const AkwabaPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AkwaabaPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
