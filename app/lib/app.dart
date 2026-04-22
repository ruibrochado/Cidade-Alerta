import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
import 'pages/main_navigation_screen.dart';
import 'routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user != null
          ? const MainNavigationScreen()
          : const LoginPage(),
      routes: AppRoutes.routes,
    );
  }
}
