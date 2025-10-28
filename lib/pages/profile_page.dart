import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/data/my_posts.dart';
import 'package:flutter_app/pages/post_page.dart'; // For PostCard and Post model
import 'package:flutter_app/main.dart'; // For themeNotifier
import 'package:flutter_app/pages/yearly_report_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // The state is managed in the static MyPosts.posts list.
  // A simple call to setState is enough to refresh the UI when needed.
  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // A key to force refresh the grid when posts change.
    final gridKey = ValueKey(MyPosts.posts.length);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Sanctuary', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const YearlyReportPage(),
              ));
            },
            tooltip: 'View Yearly Report',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, child) {
              return IconButton(
                icon: Icon(
                  currentMode == ThemeMode.light ? Icons.dark_mode_outlined : Icons.light_mode_outlined
                ),
                onPressed: () {
                  themeNotifier.value = currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                },
                tooltip: 'Toggle Theme',
              );
            },
          ),
        ],
      ),
      body: MyPosts.posts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_note_rounded, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Your personal space is empty.',
                    style: GoogleFonts.cormorantGaramond(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a post to start your collection.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: StaggeredGrid.count(
                key: gridKey,
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: MyPosts.posts.map((post) {
                  return StaggeredGridTile.count(
                    crossAxisCellCount: post.crossAxisCellCount,
                    mainAxisCellCount: post.mainAxisCellCount,
                    // isMember is set to true to always allow viewing of own posts
                    child: PostCard(post: post, isMember: true),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
