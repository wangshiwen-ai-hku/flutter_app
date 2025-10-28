import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A button composed of two SVGs: `down.svg` as background and `up.svg` as
/// the movable piece. When pressed, the `up` SVG animates downward to give
/// a pressed effect and then returns when released.
class UpDownButton extends StatefulWidget {
  final VoidCallback onTap;
  final double width;
  final double height;

  const UpDownButton({Key? key, required this.onTap, this.width = 110, this.height = 75}) : super(key: key);

  @override
  State<UpDownButton> createState() => _UpDownButtonState();
}

class _UpDownButtonState extends State<UpDownButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _offsetAnimation;
  late final Animation<double> _shadowScaleAnimation;
  late final Animation<double> _upScaleAnimation;

  @override
  void initState() {
    super.initState();
    // Controller drives the pressed state. We animate to pressed when the
    // user puts finger down and reverse when released/cancelled.
    _pressController = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));

    _offsetAnimation = Tween<double>(begin: 0.0, end: widget.height * 0.14)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));

    // shadow/background slightly squashes when pressed
    _shadowScaleAnimation = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));

    // up piece slightly scales down while moving to give depth
    _upScaleAnimation = Tween<double>(begin: 1.0, end: 0.98)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    // trigger the action when user releases
    _pressController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _pressController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Background / shadow: scale slightly to simulate compression
                Positioned.fill(
                  child: Transform.scale(
                    scale: _shadowScaleAnimation.value,
                    child: SvgPicture.asset('assets/svgs/down.svg', fit: BoxFit.contain),
                  ),
                ),
                // add space
                // The movable top piece is slightly lifted by default to create
                // a visible gap between the top and bottom pieces. When pressed
                // it translates downward by `_offsetAnimation`.
                Transform.translate(
                  offset: Offset(0, -widget.height * 0.2 + _offsetAnimation.value),
                  child: Transform.scale(
                    scale: _upScaleAnimation.value,
                    child: SizedBox(
                      width: widget.width * 0.98,
                      height: widget.height * 0.98,
                      child: SvgPicture.asset('assets/svgs/up.svg', fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


