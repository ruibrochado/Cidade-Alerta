import 'package:flutter/material.dart';

import '../models/report_data.dart';
import '../pages/adjust_location_page.dart';
//import '../pages/confirm_page.dart';
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
      final report = ModalRoute.of(context)!.settings.arguments as ReportData;
      return DetectLocationPage(report: report);
    },

    '/adjust-location': (context) {
      final report = ModalRoute.of(context)!.settings.arguments as ReportData;
      return AdjustLocationPage(report: report);
    },

    /*'/confirm': (context) {
      final report = ModalRoute.of(context)!.settings.arguments as ReportData;
      return ConfirmPage(report: report);
    },
    */
  };
}