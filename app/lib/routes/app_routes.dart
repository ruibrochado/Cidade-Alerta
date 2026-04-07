import 'package:flutter/material.dart';
import '../pages/email_test_page.dart';
import '../pages/home_page.dart';
import '../pages/issue_category_page.dart';
import '../pages/login_page.dart';
import '../pages/recycling_scanner_page.dart';
import '../pages/map_page.dart';
import '../pages/details_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginPage(),
    '/home': (context) => const HomePage(),
    '/email-test': (context) => const EmailTestPage(),
    '/scanner': (context) => const RecyclingScannerPage(),
    '/categories': (context) => const SelectCategory(),
    '/map': (context) => const MapPage(),
    //'/details': (context) => const DetailsPage(),
  };
}