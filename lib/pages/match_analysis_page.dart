import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/models/match_analysis.dart';

import 'package:flutter_app/models/match_profile.dart';
import 'package:flutter_app/pages/chat_page.dart';
import 'package:flutter_app/widgets/poetic_summary_card.dart';

class MatchAnalysisPage extends StatelessWidget {
  final MatchAnalysis analysis;

  const MatchAnalysisPage({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold);
    final subtitleStyle = GoogleFonts.cormorantGaramond(fontSize: 18, color: Colors.grey[600]);
    final bodyStyle = GoogleFonts.notoSerifSc(fontSize: 16, height: 1.5);

    // Generate a consistent color from the user's ID
    final accentColor = Colors.primaries[analysis.userB.uid.hashCode % Colors.primaries.length];

    return Scaffold(
      appBar: AppBar(
        title: Text('Match Analysis', style: GoogleFonts.cormorantGaramond(fontWeight: FontWeight.w600)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final matchedProfile = MatchProfile(
            id: analysis.userB.uid,
            name: analysis.userB.username,
            tagline: analysis.userB.freeText, // Using freeText as a tagline
            accent: accentColor,
          );
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ChatPage(profile: matchedProfile),
          ));
        },
        label: const Text('Start Chat'),
        icon: const Icon(Icons.chat_bubble_outline),
        backgroundColor: accentColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 80.0), // Add padding for FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with both users
            _buildMatchVisual(analysis.userA.username, analysis.userB.username, accentColor),
            const SizedBox(height: 32),

            // AI Score
            Center(
              child: Column(
                children: [
                  Text('Compatibility Score', style: subtitleStyle),
                  const SizedBox(height: 8),
                  Text(
                    '${(analysis.finalScore * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.josefinSans(fontSize: 56, fontWeight: FontWeight.bold, color: accentColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Poetic AI Summary
            Text('Our Thoughts', style: titleStyle),
            const SizedBox(height: 16),
            PoeticSummaryCard(analysis: analysis, accentColor: accentColor),
            const Divider(height: 48),

            // Conversation Starters
            Text('Conversation Starters', style: titleStyle),
            const SizedBox(height: 16),
            ...analysis.conversationStarters.map((starter) => _buildStarter(starter)).toList(),

            const Divider(height: 48),

            // Trait Compatibility
            Text('Trait Compatibility', style: titleStyle),
            const SizedBox(height: 16),
            Text('Formula Score: ${(analysis.formulaScore * 100).toStringAsFixed(1)}%', style: subtitleStyle),
            const SizedBox(height: 16),
            ...analysis.traitCompatibility.entries.map((entry) {
              return _buildTraitBar(theme, entry.key, entry.value, accentColor);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchVisual(String userA, String userB, Color accentColor) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 120,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 20,
              child: _buildUserAvatar(userA, Colors.blueGrey),
            ),
            Positioned(
              right: 20,
              child: _buildUserAvatar(userB, accentColor),
            ),
            // A simple connector line
            Container(
              height: 2,
              width: 80,
              color: accentColor.withOpacity(0.5),
            ),
            // Overlapping blend effect
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withOpacity(0.3),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStarter(String starter) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('"$starter"', style: GoogleFonts.notoSerifSc(fontStyle: FontStyle.italic)),
      ),
    );
  }

  Widget _buildUserAvatar(String username, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: color.withOpacity(0.2),
          child: Text(username[0].toUpperCase(), style: GoogleFonts.cormorantGaramond(fontSize: 32, color: color, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTraitBar(ThemeData theme, String trait, double score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trait, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: score,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
