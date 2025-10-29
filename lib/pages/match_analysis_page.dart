import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flip_card/flip_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_app/models/match_analysis.dart';
import 'package:flutter_app/models/match_profile.dart';
import 'package:flutter_app/pages/chat_page.dart';

class MatchAnalysisPage extends StatelessWidget {
  final MatchAnalysis analysis;

  const MatchAnalysisPage({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final accentColor = Colors.primaries[analysis.userB.uid.hashCode % Colors.primaries.length];

    return Scaffold(
      appBar: AppBar(
        title: Text('Match Analysis', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final matchedProfile = MatchProfile(
            id: analysis.userB.uid,
            name: analysis.userB.username,
            tagline: analysis.userB.freeText,
            accent: accentColor,
          );
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatPage(profile: matchedProfile),
          ));
        },
        label: const Text('Start Chat', style: TextStyle(color: Colors.black87)),
        icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
        backgroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 80.0), // Padding for FAB
        child: FlipCard(
          front: _buildFrontCard(context, accentColor),
          back: _buildBackCard(context, accentColor),
        ),
      ),
    );
  }

  Widget _buildFrontCard(BuildContext context, Color accentColor) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          gradient: LinearGradient(
            colors: [accentColor.withOpacity(0.8), accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMatchVisual(analysis.userA.username, analysis.userB.username),
              _buildTotalScore(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text('Tap to see why', style: TextStyle(color: Colors.white70)), Icon(Icons.touch_app_outlined, color: Colors.white70, size: 16)],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(BuildContext context, Color accentColor) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${analysis.matchSummary}"',
              textAlign: TextAlign.center,
              style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
            ),
            const Divider(height: 30, thickness: 0.5),
            Text(
              'In-depth Analysis',
              style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Click column to see detailed explanation',
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildBarChart(context, accentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchVisual(String userA, String userB) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildUserAvatar(userA, Colors.white),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Match',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            _buildUserAvatar(userB, Colors.white),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Similar Soul',
          style: GoogleFonts.cormorantGaramond(fontSize: 18, color: Colors.white.withOpacity(0.9)),
        ),
        const SizedBox(height: 5),
        Text(
          '$userA & $userB',
          style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildUserAvatar(String username, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: color.withOpacity(0.2),
          child: Text(username[0].toUpperCase(), style: GoogleFonts.cormorantGaramond(fontSize: 40, color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(username, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
      ],
    );
  }

  Widget _buildTotalScore() {
    return Column(
      children: [
        Text(
          'Compatibility Score',
          style: GoogleFonts.cormorantGaramond(fontSize: 22, color: Colors.white.withOpacity(0.9)),
        ),
        const SizedBox(height: 8),
        Text(
          '${(analysis.totalScore * 100).toStringAsFixed(0)}%',
          style: GoogleFonts.josefinSans(fontSize: 80, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBarChart(BuildContext context, Color accentColor) {
    final features = analysis.similarFeatures.entries.toList();
    if (features.isEmpty) {
      return const Center(child: Text('No detailed analysis available.'));
    }

    return ListView.builder(
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        final score = feature.value.score;
        final percentage = score / 100.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(feature.key),
                  content: Text(feature.value.explanation),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('关闭'),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 左侧标题和分数
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$score / 100',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // 右侧水平柱子
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          accentColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}