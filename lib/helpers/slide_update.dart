import 'package:liquid_swipe_gallery/helpers/helpers.dart';

///A model class with data specific to Update in [LiquidController]
class SlideUpdate {
  final UpdateType updateType;
  final SlideDirection direction;
  final double slidePercentHor;
  final double slidePercentVer;

  SlideUpdate(
    this.direction,
    this.slidePercentHor,
    this.slidePercentVer,
    this.updateType,
  );
}
