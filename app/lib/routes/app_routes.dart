import 'package:app/pages/profile_page.dart';
import 'package:flutter/material.dart';
import '../models/report_data.dart';
import '../pages/adjust_location_page.dart';
import '../pages/confirm_report_page.dart';
import '../pages/detect_location_page.dart';
import '../pages/email_test_page.dart';
import '../pages/issue_category_page.dart';
import '../pages/signin_page.dart';
import '../pages/main_navigation_screen.dart';
import '../pages/edit_profile_page.dart';
import '../pages/terms_privacy_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/login': (context) => const LoginPage(),

    // Main entry after login
    '/home': (context) => const MainNavigationScreen(),

    '/email-test': (context) => const EmailTestPage(),
    '/categories': (context) => const SelectCategory(),

    // Optional direct tab routes
    '/feed': (context) => const MainNavigationScreen(initialIndex: 0),
    '/profile': (context) => const ProfilePage(),
    '/edit-profile': (context) => const EditProfilePage(),
    '/privacy-terms': (context) => const TermsPrivacyPage(),
    '/scanner': (context) => const MainNavigationScreen(initialIndex: 1),
    '/map': (context) => const MainNavigationScreen(initialIndex: 2),

    '/detect-location': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ReportData) {
        return DetectLocationPage(report: args);
      }
      return const DetectLocationPage(report: ReportData(category: 'Geral'));
    },

    '/adjust-location': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ReportData) {
        return AdjustLocationPage(report: args);
      }
      return const MainNavigationScreen();
    },

    '/confirm': (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ReportData) {
        return ConfirmPage(report: args);
      }

      debugPrint('ERROR: /confirm opened without ReportData');
      return const MainNavigationScreen();
    },
  };
}
