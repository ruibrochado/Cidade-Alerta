import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../pages/adjust_location_page.dart';
import '../pages/confirm_report_page.dart';
import '../pages/detect_location_page.dart';
import '../pages/email_test_page.dart';
import '../pages/home_page.dart';
import '../pages/issue_category_page.dart';
import '../pages/login_page.dart';
import '../pages/map_page.dart';
import '../pages/recycling_scanner_page.dart';
import '../pages/feed_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginPage(),
    '/home': (context) => const HomePage(),
    '/email-test': (context) => const EmailTestPage(),
    '/scanner': (context) => const RecyclingScannerPage(),
    '/categories': (context) => const SelectCategory(),
    '/map': (context) => const MapPage(),
    '/feed': (context) => const FeedPage(),

    '/detect-location': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ReportData) {
        return DetectLocationPage(report: args);
      }
      return const DetectLocationPage(report: ReportData(category: 'Geral'));
    },

    '/adjust-location': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ReportData) return AdjustLocationPage(report: args);
      return const HomePage();
    },

    '/confirm': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ReportData) return ConfirmPage(report: args);

      // Se chegar aqui sem dados, avisa mas não crasha a rota
      debugPrint("ERRO: /confirm sem ReportData!");
      return const HomePage();
    },
  };
}
