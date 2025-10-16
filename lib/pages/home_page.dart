import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/up_down_button.dart';
import 'canvas_drawing_page.dart';
import 'match_result_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final Set<String> _selectedTraits = <String>{};
  final TextEditingController _shareController = TextEditingController();
  Uint8List? _profileDrawing;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _shareController.dispose();
    super.dispose();
  }

  void _startMatching() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MatchResultPage()),
    );
  }

  Future<void> _openCanvas() async {
    final result = await Navigator.push<Uint8List?>(
      context,
      MaterialPageRoute(
        builder: (context) => const CanvasDrawingPage(),
        fullscreenDialog: true,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _profileDrawing = result;
      });
    }
  }

  void _toggleTrait(String label) {
    setState(() {
      if (_selectedTraits.contains(label)) {
        _selectedTraits.remove(label);
      } else {
        _selectedTraits.add(label);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double contentMaxWidth = math.min(constraints.maxWidth, 520);
            final double cardWidth = math.min(contentMaxWidth, 420);
            final double shareWidth = math.min(contentMaxWidth * 0.9, 360);
            final double scale =
                (constraints.maxHeight / 760).clamp(0.72, 1.0).toDouble();
            final double headingSize = 28 + (8 * scale);
            final double verticalGap = 10 * scale;
            final double miniGap = 6 * scale;
            final double gridHeight = (220 * scale).clamp(160, 240);
            final double buttonScale = scale.clamp(0.8, 1.0).toDouble();
            final double arrowHeight = 96 * scale.clamp(0.7, 1.0).toDouble();

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: contentMaxWidth,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Psycho',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: headingSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      SizedBox(height: verticalGap),
                      Flexible(
                        fit: FlexFit.loose,
                        child: TraitSelectionCard(
                          width: cardWidth,
                          gridHeight: gridHeight,
                          selectedTraits: _selectedTraits,
                          onTraitTap: _toggleTrait,
                          onProfileTap: _openCanvas,
                          profileDrawing: _profileDrawing,
                          scale: scale,
                        ),
                      ),
                      SizedBox(height: verticalGap),
                      SharePromptInput(
                        width: shareWidth,
                        controller: _shareController,
                        scale: scale,
                      ),
                      SizedBox(height: verticalGap),
                      SizedBox(
                        width: shareWidth,
                        height: arrowHeight,
                        child: SvgPicture.asset(
                          'assets/svgs/arrow.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: miniGap),
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Column(
                          children: [
                            UpDownButton(
                              width: 120 * buttonScale,
                              height: 84 * buttonScale,
                              onTap: _startMatching,
                            ),
                            SizedBox(height: miniGap),
                            Text(
                              'Match Me!',
                              style: GoogleFonts.courgette(
                                fontSize: 22 + (4 * scale),
                                color: const Color(0xFF992121),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: verticalGap),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TraitSelectionCard extends StatelessWidget {
  final double width;
  final double gridHeight;
  final Set<String> selectedTraits;
  final ValueChanged<String> onTraitTap;
  final VoidCallback onProfileTap;
  final Uint8List? profileDrawing;
  final double scale;

  const TraitSelectionCard({
    super.key,
    required this.width,
    required this.gridHeight,
    required this.selectedTraits,
    required this.onTraitTap,
    required this.onProfileTap,
    required this.profileDrawing,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    const cells = <_TraitCellData>[
      _TraitCellData(label: 'profile\nself draw\ncanvas', isProfile: true),
      _TraitCellData(label: 'storyteller'),
      _TraitCellData(label: 'listener'),
      _TraitCellData(label: 'dream log'),
      _TraitCellData(label: 'night owl'),
      _TraitCellData(label: 'world builder'),
      _TraitCellData(label: 'observer'),
      _TraitCellData(label: 'mood board'),
      _TraitCellData(label: 'writer'),
      _TraitCellData(label: 'sound hunt'),
      _TraitCellData(label: 'rituals'),
      _TraitCellData(label: 'sketches'),
    ];

    final double normalizedBorder = scale.clamp(0.7, 1.0).toDouble();
    final double paddingFactor = scale.clamp(0.75, 1.0).toDouble();
    final double horizontalPadding = 18 * paddingFactor;
    final double verticalPadding = 18 * paddingFactor;
    final double titleSize = 17 + (3 * scale);
    final double spacing = 10 * scale;
    final double borderRadius = 22 * normalizedBorder;
    final double cellRadius = 14 * normalizedBorder;
    final double crossAxisSpacing = 12 * normalizedBorder;
    final double mainAxisSpacing = crossAxisSpacing;
    final int crossAxisCount;
    if (width >= 420) {
      crossAxisCount = 4;
    } else if (width >= 320) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }
    final int rows = (cells.length / crossAxisCount).ceil();
    final double minCellHeight = 52 * scale;
    final double minGridHeight =
        rows * minCellHeight + (rows - 1) * mainAxisSpacing;
    final double targetGridHeight = math.max(gridHeight, minGridHeight);
    final double rawContentWidth = width -
        (2 * horizontalPadding) -
        (crossAxisCount - 1) * crossAxisSpacing;
    final double contentWidth = rawContentWidth > 0 ? rawContentWidth : width;
    final double cellWidth = contentWidth / crossAxisCount;
    final double availableHeightForCells =
        targetGridHeight - (rows - 1) * mainAxisSpacing;
    final double rawCellHeight = availableHeightForCells / rows;
    final double safeCellHeight = rawCellHeight > 0 ? rawCellHeight : cellWidth;
    final double aspectRatio = cellWidth / safeCellHeight;

    return Container(
      width: width,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F3),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFF403433), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select traits & match',
              style: GoogleFonts.cormorantGaramond(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: spacing),
          SizedBox(
            height: targetGridHeight,
            child: GridView.builder(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cells.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (context, index) {
                final cell = cells[index];
                final isSelected = selectedTraits.contains(cell.label);
                return _TraitCell(
                  data: cell,
                  isSelected: isSelected,
                  onTap: cell.isProfile
                      ? onProfileTap
                      : () => onTraitTap(cell.label),
                  profileDrawing: profileDrawing,
                  cellRadius: cellRadius,
                  scale: scale,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SharePromptInput extends StatelessWidget {
  final double width;
  final TextEditingController controller;
  final double scale;

  const SharePromptInput({
    super.key,
    required this.width,
    required this.controller,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final double normalized = scale.clamp(0.7, 1.0).toDouble();
    final double paddingFactor = scale.clamp(0.75, 1.0).toDouble();
    final double textSize = 18 + (2 * scale);
    final double hintSize = 17 + (2 * scale);
    final double minHeight = 90 * normalized;
    final int maxLines = scale < 0.85 ? 2 : 3;
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * paddingFactor,
        vertical: 10 * paddingFactor,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3D302F), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.cormorantGaramond(
          fontSize: textSize,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF463737),
        ),
        decoration: InputDecoration(
          hintText: 'what you want here',
          hintStyle: GoogleFonts.cormorantGaramond(
            fontSize: hintSize,
            color: const Color(0xFF8F7B7A),
          ),
          border: InputBorder.none,
        ),
        cursorColor: const Color(0xFF992121),
      ),
    );
  }
}

class _TraitCellData {
  final String label;
  final bool isProfile;

  const _TraitCellData({required this.label, this.isProfile = false});
}

class _TraitCell extends StatelessWidget {
  final _TraitCellData data;
  final bool isSelected;
  final VoidCallback onTap;
  final Uint8List? profileDrawing;
  final double cellRadius;
  final double scale;

  const _TraitCell({
    required this.data,
    required this.isSelected,
    required this.onTap,
    required this.profileDrawing,
    required this.cellRadius,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final bool showImage = data.isProfile && profileDrawing != null;
    final Color baseColor;
    final Color textColor;

    if (data.isProfile) {
      baseColor = const Color(0xFFE8B3B1);
      textColor = const Color(0xFF3B2524);
    } else if (isSelected) {
      baseColor = const Color(0xFF992121);
      textColor = const Color(0xFFFDF7F5);
    } else {
      baseColor = const Color(0xFF7A6C6C);
      textColor = const Color(0xFFF4ECE9);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(cellRadius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x15000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
          border: data.isProfile
              ? Border.all(color: const Color(0xFF5F4040), width: 1.3)
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: showImage
              ? ClipRRect(
                  key: const ValueKey('profile-image'),
                  borderRadius:
                      BorderRadius.circular(math.max(cellRadius - 2, 8)),
                  child: Image.memory(
                    profileDrawing!,
                    fit: BoxFit.cover,
                  ),
                )
              : Center(
                  child: Text(
                    data.label,
                    key: ValueKey('${data.label}-${isSelected ? 'on' : 'off'}'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 13 + (2.5 * scale),
                      color: textColor,
                      height: 1.1,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
