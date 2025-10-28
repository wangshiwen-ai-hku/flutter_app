import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YearlyReportPage extends StatelessWidget {
  const YearlyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headingStyle = GoogleFonts.cormorantGaramond(
      fontWeight: FontWeight.bold,
      fontSize: 32,
      color: theme.textTheme.bodyLarge?.color,
    );
    final bodyStyle = GoogleFonts.notoSerifSc(
      fontSize: 16,
      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 250.0,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Your Journey', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold)),
              background: Container(
                color: theme.colorScheme.surface,
                child: Center(
                  child: Text(
                    '2025',
                    style: GoogleFonts.marckScript(fontSize: 100, color: theme.primaryColor.withOpacity(0.5)),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, Wanderer', style: headingStyle),
                  const SizedBox(height: 8),
                  Text(
                    "This year, you've explored the depths of your inner world and connected with others on a unique plane. Here is a reflection of your journey...",
                    style: bodyStyle,
                  ),
                ],
              ),
            ),
          ),
          _buildStatCard(
            title: 'Connections Made',
            stat: '12',
            description: "You've opened your world to 12 other souls, sharing moments and thoughts.",
            icon: Icons.people_alt_outlined,
          ),
          _buildTraitChartCard(
            title: 'Your Core Traits',
            description: 'This is the constellation of your personality this year.',
            // Mock data for the chart
            traitData: {
              'storyteller': 5,
              'dream log': 8,
              'night owl': 3,
              'observer': 6,
            },
          ),
          _buildPortraitHistoryCard(
            title: 'The Faces of You',
            description: 'A timeline of your self-perception.',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'The journey continues...',
                  style: headingStyle.copyWith(fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required String stat, required String description, required IconData icon}) {
    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.grey[400]),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 8),
                    Text(stat, style: GoogleFonts.josefinSans(fontWeight: FontWeight.bold, fontSize: 36, color: const Color(0xFF992121))),
                    const SizedBox(height: 8),
                    Text(description, style: GoogleFonts.notoSerifSc(color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraitChartCard({required String title, required String description, required Map<String, int> traitData}) {
    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 8),
              Text(description, style: GoogleFonts.notoSerifSc(color: Colors.grey[600])),
              const SizedBox(height: 24),
              // Simple bar chart made with containers
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxValue = traitData.values.reduce((a, b) => a > b ? a : b);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: traitData.entries.map((entry) {
                      final barHeight = (entry.value / maxValue) * 100;
                      return Column(
                        children: [
                          Container(
                            height: barHeight,
                            width: constraints.maxWidth / traitData.length / 2,
                            color: const Color(0xFF992121).withOpacity(0.7),
                          ),
                          const SizedBox(height: 4),
                          Text(entry.key, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitHistoryCard({required String title, required String description}) {
    return SliverToBoxAdapter(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 8),
              Text(description, style: GoogleFonts.notoSerifSc(color: Colors.grey[600])),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: List.generate(4, (index) => Card(
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      width: 100,
                      height: 120,
                      color: Colors.grey[200],
                      child: Center(child: Icon(Icons.face_retouching_natural, color: Colors.grey[400])),
                    ),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
