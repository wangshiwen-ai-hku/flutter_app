import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_app/pages/feature_selection_page.dart';
import 'package:flutter_app/pages/match_result_page.dart';
import 'package:flutter_app/pages/post_page.dart';
import 'package:flutter_app/pages/profile_page.dart'; // Import the new profile page
import 'package:flutter_app/widgets/bottom_nav_bar_visibility_notification.dart';
import 'package:flutter_app/widgets/change_tab_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isNavBarVisible = true;

  // Add a fourth key for the new navigator
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        final navigator = _navigatorKeys[_selectedIndex].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Scaffold(
        body: NotificationListener<ChangeTabNotification>(
          onNotification: (notification) {
            _onItemTapped(notification.index);
            return true;
          },
          child: NotificationListener<BottomNavBarVisibilityNotification>(
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
            // Add a fourth Navigator to the IndexedStack
            child: IndexedStack(
              index: _selectedIndex,
              children: <Widget>[
                Navigator(
                  key: _navigatorKeys[0],
                  onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => const FeatureSelectionPage()),
                ),
                Navigator(
                  key: _navigatorKeys[1],
                  onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => const MatchResultPage()),
                ),
                Navigator(
                  key: _navigatorKeys[2],
                  onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => const PostPage()),
                ),
                Navigator(
                  key: _navigatorKeys[3],
                  onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => ProfilePage()),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _isNavBarVisible ? 0 : kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom, 0),
          transformAlignment: Alignment.bottomCenter,
          // Add a fourth item to the BottomNavigationBar
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                // This is the original first tab, now using a new icon.
                icon: SvgPicture.asset('assets/svgs/github.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                activeIcon: SvgPicture.asset('assets/svgs/github.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF992121), BlendMode.srcIn)),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/svgs/match.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                activeIcon: SvgPicture.asset('assets/svgs/match.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF992121), BlendMode.srcIn)),
                label: 'Match',
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset('assets/svgs/post.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                activeIcon: SvgPicture.asset('assets/svgs/post.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF992121), BlendMode.srcIn)),
                label: 'Post',
              ),
              BottomNavigationBarItem(
                // New fourth tab for the user's profile page, now using the correct icon.
                icon: SvgPicture.asset('assets/svgs/profile.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                activeIcon: SvgPicture.asset('assets/svgs/profile.svg', width: 24, height: 24, colorFilter: const ColorFilter.mode(Color(0xFF992121), BlendMode.srcIn)),
                label: 'Profile',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF992121),
            onTap: _onItemTapped,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: const Color(0xFFF8F5F3),
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }
}
