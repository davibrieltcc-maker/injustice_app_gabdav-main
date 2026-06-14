import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'core/di/dependency_injection.dart';
import 'core/firebase/firebase_options.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart' as AppTheme;
import 'core/theme/theme_controller.dart';
import 'data/services/auth_service_interface.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupDependencyInjection();
  final themeController = injector.get<ThemeController>();
  final authService = injector.get<IAuthService>();

  runApp(
    Watch(
      (_) => StreamBuilder(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Injustice App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode.value,
            routerConfig: AppRouter.router,
          );
        },
      ),
    ),
  );
}
