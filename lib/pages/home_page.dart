import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/pages/feature_selection_page.dart';
import 'package:flutter_app/pages/match_result_page.dart';
import 'package:flutter_app/pages/post_page.dart';
import 'package:flutter_app/pages/profile_page.dart'; // Import the new profile page
import 'package:flutter_app/widgets/bottom_nav_bar_visibility_notification.dart';
import 'package:flutter_app/widgets/change_tab_notification.dart';
import 'package:flutter_app/widgets/up_down_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isNavBarVisible = true;

  final List<Widget> _pages = [
    const PostPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onMatchButtonTapped() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const FeatureSelectionPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // This PopScope is essential for handling back-button presses on Android
    // when using nested Navigators, though for this 1-level deep design,
    // its primary role is to prevent exiting the app accidentally.
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        setState(() {
          _selectedIndex = 0;
        });
      },
      child: Scaffold(
        body: NotificationListener<BottomNavBarVisibilityNotification>(
          onNotification: (notification) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _isNavBarVisible != notification.isVisible) {
                setState(() {
                  _isNavBarVisible = notification.isVisible;
                });
              }
            });
            return true;
          },
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
        floatingActionButton: AnimatedScale(
          duration: const Duration(milliseconds: 300),
          scale: _isNavBarVisible ? 1.0 : 0.0,
          child: UpDownButton(
            onTap: _onMatchButtonTapped,
            width: 90, // Resized
            height: 60, // Resized
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isNavBarVisible ? 80.0 : 0,
          child: BottomAppBar(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _buildNavItem(iconAsset: 'assets/svgs/post.svg', index: 0, label: 'World'),
                const SizedBox(width: 48), // The space for the FAB
                _buildNavItem(iconAsset: 'assets/svgs/profile.svg', index: 1, label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required String iconAsset, required int index, required String label}) {
    final isSelected = _selectedIndex == index;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).unselectedWidgetColor;
    return IconButton(
      icon: SvgPicture.asset(iconAsset, width: 24, height: 24, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
      onPressed: () => _onItemTapped(index),
      tooltip: label,
    );
  }
}
