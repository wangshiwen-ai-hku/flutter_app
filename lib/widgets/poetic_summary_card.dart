
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/models/match_analysis.dart';

class PoeticSummaryCard extends StatelessWidget {
  final MatchAnalysis analysis;
  final Color accentColor;

  const PoeticSummaryCard({
    super.key,
    required this.analysis,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bodyStyle = GoogleFonts.notoSerifSc(fontSize: 16, height: 1.5, color: Colors.white);

    return Card(
      elevation: 8,
      shadowColor: accentColor.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [accentColor.withOpacity(0.8), accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              '"${analysis.matchSummary}"',
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
            const SizedBox(height: 24),
            _buildUserAvatars(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildUserAvatar(analysis.userA.username, Colors.blueGrey),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Icon(Icons.favorite, color: Colors.white.withOpacity(0.8)),
        ),
        _buildUserAvatar(analysis.userB.username, Colors.white),
      ],
    );
  }

  Widget _buildUserAvatar(String username, Color color) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            username[0].toUpperCase(),
            style: GoogleFonts.cormorantGaramond(
              fontSize: 24,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          username,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
