import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/change_tab_notification.dart';
import '../widgets/up_down_button.dart';
import 'canvas_drawing_page.dart';

class FeatureSelectionPage extends StatefulWidget {
  const FeatureSelectionPage({super.key});

  @override
  State<FeatureSelectionPage> createState() => _FeatureSelectionPageState();
}

class _FeatureSelectionPageState extends State<FeatureSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _matchButtonAnimationController;
  late Animation<double> _matchButtonScaleAnimation;
  final Set<String> _selectedTraits = <String>{};
  final TextEditingController _shareController = TextEditingController();
  Uint8List? _profileDrawing;

  bool _isDrawing = false;
  final _drawingController = DrawingController();
  final GlobalKey _canvasKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _matchButtonAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _matchButtonScaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _matchButtonAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _matchButtonAnimationController.dispose();
    _shareController.dispose();
    _drawingController.dispose();
    super.dispose();
  }

  void _startMatching() {
    ChangeTabNotification(1).dispatch(context);
  }

  void _openCanvas() {
    setState(() => _isDrawing = true);
  }

  Future<void> _finishDrawing() async {
    try {
      final boundary =
          _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      if (mounted) {
        setState(() {
          _profileDrawing = pngBytes;
          _isDrawing = false;
        });
      }
    } catch (e) {
      // Handle error
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
    final theme = Theme.of(context);
    const headingColor = Color(0xFF4F4A45);
    const shareTextColor = Color(0xFF6B645E);

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double contentMaxWidth = math.min(constraints.maxWidth, 520);
                final double cardWidth = math.min(contentMaxWidth, 420);
                final double shareWidth = cardWidth; // Align width
                final double scale =
                    (constraints.maxHeight / 800).clamp(0.8, 1.0).toDouble();
                final double buttonScale = scale.clamp(0.8, 1.0).toDouble();

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Psycho',
                          style: GoogleFonts.marckScript(
                            fontSize: 52 * scale,
                            fontWeight: FontWeight.w500,
                            color: headingColor,
                          ),
                        ),
                        TraitSelectionCard(
                          width: cardWidth,
                          selectedTraits: _selectedTraits,
                          onTraitTap: _toggleTrait,
                          onProfileTap: _openCanvas,
                          profileDrawing: _profileDrawing,
                          scale: scale,
                        ),
                        SharePromptInput(
                          width: shareWidth,
                          controller: _shareController,
                          scale: scale,
                          textColor: shareTextColor,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: 100 * scale,
                              height: 60 * scale,
                              child: SvgPicture.asset(
                                'assets/svgs/arrow.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ScaleTransition(
                              scale: _matchButtonScaleAnimation,
                              child: Column(
                                children: [
                                  UpDownButton(
                                    width: 120 * buttonScale,
                                    height: 84 * buttonScale,
                                    onTap: _startMatching,
                                  ),
                                  SizedBox(height: 6 * scale),
                                  Text(
                                    'Match Me!',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontSize: 24 * scale,
                                      color: const Color(0xFF992121),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _DrawingOverlay(
            isDrawing: _isDrawing,
            controller: _drawingController,
            canvasKey: _canvasKey,
            onFinish: _finishDrawing,
            onCancel: () => setState(() => _isDrawing = false),
            onPickImage: () {},
          ),
        ],
      ),
    );
  }
}

class TraitSelectionCard extends StatelessWidget {
  final double width;
  final Set<String> selectedTraits;
  final ValueChanged<String> onTraitTap;
  final VoidCallback onProfileTap;
  final Uint8List? profileDrawing;
  final double scale;

  const TraitSelectionCard({
    super.key,
    required this.width,
    required this.selectedTraits,
    required this.onTraitTap,
    required this.onProfileTap,
    this.profileDrawing,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cells = <_TraitCellData>[
      _TraitCellData(label: 'profile', isProfile: true),
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

    return Container(
      width: width,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCFB),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(color: const Color(0xFFEBE6E1), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD9D5D1).withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select traits & match',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontSize: 20 * scale, fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(height: 12 * scale),
          GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cells.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10 * scale,
              mainAxisSpacing: 10 * scale,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final cell = cells[index];
              final isSelected = selectedTraits.contains(cell.label);
              return _TraitCell(
                data: cell,
                isSelected: isSelected,
                onTap:
                    cell.isProfile ? onProfileTap : () => onTraitTap(cell.label),
                profileDrawing: profileDrawing,
                scale: scale,
              );
            },
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
  final Color textColor;

  const SharePromptInput({
    super.key,
    required this.width,
    required this.controller,
    required this.scale,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFCFB),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: const Color(0xFFEBE6E1), width: 1.5),
      ),
      child: TextField(
        controller: controller,
        maxLines: 2,
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontSize: 18 * scale, color: textColor),
        decoration: InputDecoration(
          hintText: 'what you want here',
          hintStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontSize: 18 * scale, color: const Color(0xFFC2BDB8)),
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

class _TraitCell extends StatefulWidget {
  final _TraitCellData data;
  final bool isSelected;
  final VoidCallback onTap;
  final Uint8List? profileDrawing;
  final double scale;

  const _TraitCell({
    required this.data,
    required this.isSelected,
    required this.onTap,
    this.profileDrawing,
    required this.scale,
  });

  @override
  State<_TraitCell> createState() => _TraitCellState();
}

class _TraitCellState extends State<_TraitCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
    _animationController.forward().then((_) => _animationController.reverse());
  }

  @override
  Widget build(BuildContext context) {
    final bool showImage = widget.data.isProfile && widget.profileDrawing != null;
    final Color selectedColor = const Color(0xFFD15353);
    final Color defaultColor = const Color(0xFFEAE5E1);
    final Color profileColor = const Color(0xFFF2D4D3);

    final Color baseColor = widget.data.isProfile
        ? profileColor
        : widget.isSelected
            ? selectedColor
            : defaultColor;
    final Color contentColor =
        widget.isSelected ? Colors.white : const Color(0xFF6B645E);

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(16 * widget.scale),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: showImage
                ? ClipRRect(
                    key: const ValueKey('profile-image'),
                    borderRadius: BorderRadius.circular(16 * widget.scale),
                    child: Image.memory(widget.profileDrawing!, fit: BoxFit.cover),
                  )
                : (widget.data.isProfile
                    ? Icon(Icons.motion_photos_on_outlined,
                        color: selectedColor, size: 32 * widget.scale)
                    : Center(
                        child: Text(
                          widget.data.label,
                          key: ValueKey(
                              '${widget.data.label}-${widget.isSelected ? 'on' : 'off'}'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14 * widget.scale,
                                color: contentColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      )),
          ),
        ),
      ),
    );
  }
}

// The Drawing Overlay and its components
class _DrawingOverlay extends StatelessWidget {
  final bool isDrawing;
  final DrawingController controller;
  final GlobalKey canvasKey;
  final VoidCallback onFinish;
  final VoidCallback onCancel;
  final VoidCallback onPickImage;

  const _DrawingOverlay({
    required this.isDrawing,
    required this.controller,
    required this.canvasKey,
    required this.onFinish,
    required this.onCancel,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isDrawing,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isDrawing ? 1.0 : 0.0,
        child: Stack(
          children: [
            BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Draw your portrait',
                      style: GoogleFonts.cormorantGaramond(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF7F2),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
                    ),
                    child: RepaintBoundary(
                      key: canvasKey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: DrawingCanvas(controller: controller),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _DrawingToolbar(
                    controller: controller,
                    onPickImage: onPickImage,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withOpacity(0.8)),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: onFinish,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF992121),
                          foregroundColor: Colors.white, // Explicitly set text color for contrast
                        ),
                        child: const Text('Finish'),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawingToolbar extends AnimatedWidget {
  final DrawingController controller;
  final VoidCallback onPickImage;

  const _DrawingToolbar({required this.controller, required this.onPickImage})
      : super(listenable: controller);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.undo, color: Colors.white), onPressed: controller.canUndo ? controller.undo : null),
          IconButton(icon: const Icon(Icons.redo, color: Colors.white), onPressed: controller.canRedo ? controller.redo : null),
          const _VerticalDivider(),
          _BrushButton(icon: Icons.edit_outlined, type: BrushType.pen, controller: controller),
          _BrushButton(icon: Icons.brush_outlined, type: BrushType.marker, controller: controller),
          const _VerticalDivider(),
          ...[const Color(0xFF4F4A45), const Color(0xFFD15353), const Color(0xFF6A8A82), const Color(0xFFD9A662), const Color(0xFF888888)].map((color) => _ColorButton(color: color, controller: controller)),
          const _VerticalDivider(),
          IconButton(icon: const Icon(Icons.image_outlined, color: Colors.white), onPressed: onPickImage),
          IconButton(icon: const Icon(Icons.clear, color: Colors.white), onPressed: controller.clear),
        ],
      ),
    );
  }
}

class _BrushButton extends StatelessWidget {
  final IconData icon;
  final BrushType type;
  final DrawingController controller;

  const _BrushButton({
    required this.icon,
    required this.type,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = controller.brushType == type;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.white),
      onPressed: () => controller.setBrushType(type),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final DrawingController controller;
  const _ColorButton({required this.color, required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = controller.currentPaint.color == color;
    return GestureDetector(
      onTap: () => controller.setColor(color),
      child: Container(
        width: 24,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent, width: 2),
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}