import 'package:flutter/material.dart';
import 'package:liquid_swipe_gallery/helpers/helpers.dart';
import 'package:liquid_swipe_gallery/helpers/slide_update.dart';
import 'package:liquid_swipe_gallery/liquid_provider.dart';
import 'package:provider/provider.dart';

class PageDragger extends StatefulWidget {
  final double fullTransitionPX;

  final Widget? slideIconWidget;

  final double? iconPosition;

  final bool ignoreUserGestureWhileAnimating;

  const PageDragger({
    super.key,
    this.fullTransitionPX = fullTransitionPx,
    this.slideIconWidget,
    this.iconPosition,
    this.ignoreUserGestureWhileAnimating = false,
  });

  @override
  State<PageDragger> createState() => _PageDraggerState();
}

class _PageDraggerState extends State<PageDragger> {
  final GlobalKey _keyIcon = GlobalKey();

  Offset? dragStart;

  SlideDirection slideDirection = SlideDirection.none;

  double slidePercentHor = 0.0;

  double slidePercentVer = 0.0;

  onDragStart(DragStartDetails details) {
    final model = Provider.of<LiquidProvider>(context, listen: false);

    if (model.isAnimating && widget.ignoreUserGestureWhileAnimating ||
        model.isUserGestureDisabled) {
      return;
    }
    dragStart = details.globalPosition;
  }

  onDragUpdate(DragUpdateDetails details) {
    if (dragStart != null) {
      final newPosition = details.globalPosition;
      final dx = dragStart!.dx - newPosition.dx;
      final dy = newPosition.dy;

      slideDirection = SlideDirection.none;
      if (dx > 0.0) {
        slideDirection = SlideDirection.rightToLeft;
      } else if (dx < 0.0) {
        slideDirection = SlideDirection.leftToRight;
      }

      if (slideDirection != SlideDirection.none) {
        slidePercentHor = (dx / widget.fullTransitionPX).abs().clamp(0.0, 1.0);
        slidePercentVer =
            (dy / MediaQuery.of(context).size.height).abs().clamp(0.0, 1.0);
      }

      Provider.of<LiquidProvider>(context, listen: false)
          .updateSlide(SlideUpdate(
        slideDirection,
        slidePercentHor,
        slidePercentVer,
        UpdateType.dragging,
      ));
    }
  }

  onDragEnd(DragEndDetails details) {
    Provider.of<LiquidProvider>(context, listen: false).updateSlide(SlideUpdate(
      SlideDirection.none,
      slidePercentHor,
      slidePercentVer,
      UpdateType.doneDragging,
    ));

    slidePercentHor = slidePercentVer = 0;
    slideDirection = SlideDirection.none;
    dragStart = null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.slideIconWidget != null) {
        Provider.of<LiquidProvider>(context, listen: false)
            .setIconSize(_keyIcon.currentContext!.size!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<LiquidProvider>(context, listen: false);

    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragStart: model.isInProgress ? null : onDragStart,
        onHorizontalDragUpdate: model.isInProgress ? null : onDragUpdate,
        onHorizontalDragEnd: model.isInProgress ? null : onDragEnd,
        child: Align(
          alignment: Alignment(
            1 - slidePercentHor,
            -1.0 + Utils.handleIconAlignment(widget.iconPosition!) * 2,
          ),
          child: Opacity(
            opacity: 1 - slidePercentHor,
            child: slideDirection != SlideDirection.leftToRight &&
                    widget.slideIconWidget != null
                ? SizedBox(
                    key: _keyIcon,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 10.0),
                      child: widget.slideIconWidget,
                    ),
                  )
                : null,
          ),
        ));
  }
}
