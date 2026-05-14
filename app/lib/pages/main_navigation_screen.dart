import 'package:flutter/material.dart';
import 'package:app/widgets/navbar.dart';
import 'feed_page.dart';
import 'recycling_scanner_page.dart';
import 'map_page.dart';
import 'activity_page.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  late final List<Widget> _pages = [
    const FeedPage(),
    const RecyclingScannerPage(),
    const MapPage(),
    const ActivityPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openReportFlow() {
    Navigator.pushNamed(context, '/categories');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabSelected,
        onReportTap: _openReportFlow,
      ),
    );
  }
}
