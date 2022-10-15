library liquid_swipe_gallery;

//  Created by Bomsamdi on 2022
//  Copyright © 2022 Bomsamdi. All rights reserved.
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:liquid_swipe_gallery/helpers/helpers.dart';
import 'package:liquid_swipe_gallery/helpers/liquid_swipe_child_delegate.dart';
import 'package:liquid_swipe_gallery/liquid_provider.dart';
import 'package:liquid_swipe_gallery/page_helpers/liquid_controller.dart';
import 'package:liquid_swipe_gallery/page_helpers/page_dragger.dart';
import 'package:liquid_swipe_gallery/page_helpers/page_reveal.dart';
import 'package:provider/provider.dart';

final key = GlobalKey<_LiquidSwipeGalleryState>();

/// Callback to provide the current page Index whenever it changes
///
/// Returns an [int] value.
///
/// Simple Usage :
///
/// Create your own method
///
/// ```dart
/// pageChangeCallback(int page) {
///   ...performActions
/// }
/// ```
/// add this methods as callback to [LiquidSwipeGallery.onPageChangeCallback]
///
/// ```dart
///     LiquidSwipeGallery(
///       pages: pages,
///       onPageChangeCallback: pageChangeCallback,
///     ),
/// ```
///
/// see also : [LiquidController.currentPage]
typedef OnPageChangeCallback = void Function(int activePageIndex);

/// Callback to provide the current UpdateType
///
/// Returns an [UpdateType] value.
///
/// Simple Usage :
///
/// Create your own method
///
/// ```dart
/// updateChangeCallback(UpdateType type) {
///   ...performActions
/// }
/// ```
/// add this methods as callback to [LiquidSwipeGallery.currentUpdateTypeCallback]
///
/// ```dart
///     LiquidSwipeGallery(
///       pages: pages,
///       currentUpdateTypeCallback: updateChangeCallback,
///     ),
/// ```
typedef CurrentUpdateTypeCallback = void Function(UpdateType updateType);

/// Callback to provide the slidePercentage, both vertical and horizontal
///
/// Returns two [double] values.
///
/// Simple Usage :
///
/// use [LiquidSwipeGallery.slidePercentCallback] for callbacks
///
/// ```dart
///     LiquidSwipeGallery(
///       pages: pages,
///       slidePercentCallback: (slidePercentHorizontal, slidePercentVertical) => {
///             ...performActions
///       },
///     ),
/// ```
typedef SlidePercentCallback = void Function(
    double slidePercentHorizontal, double slidePercentVertical);

/// LiquidSwipeGallery widget for out of the box Animation between stacked Widgets.
///
/// For Simple Usage LiquidSwipeGallery just requires List of Widgets and assign it to [LiquidSwipeGallery.pages]
///
/// Pages can be or should be Containers or SizedBox etc. Please report if doesn't work on some specific type of the Widgets
///
/// Example :
///
/// ```dart
///     LiquidSwipeGallery(
///       pages: pages,
///     ),
/// ```
///
/// All Other parameters are optional and can be neglected, otherwise see documentation related to each of them.
///
/// An Example of LiquidSwipeGallery with Default values (excluding callbacks) :
///
/// [LiquidSwipeGallery()]
/// ```dart
///       LiquidSwipeGallery(
///           pages: pages,
///           fullTransitionValue: FULL_TRANSITION_PX,
///           initialPage: 0,
///           enableSlideIcon: false,
///           slideIconWidget: const Icon(Icons.arrow_back_ios),
///           positionSlideIcon: 0.54,
///           enableLoop: true,
///           waveType: WaveType.liquidReveal,
///           liquidController: liquidController,
///           disableUserGesture: false,
///           ignoreUserGestureWhileAnimating: false,
///        ),
/// ```
///
/// [LiquidSwipeGallery.builder(itemBuilder: itemBuilder, itemCount: itemCount)]
/// ```dart
///       LiquidSwipeGallery.builder(
///           itemCount : data.length,
///           itemBuilder : (context, index) => Container(...),
///           fullTransitionValue: FULL_TRANSITION_PX,
///           initialPage: 0,
///           enableSlideIcon: false,
///           slideIconWidget: const Icon(Icons.arrow_back_ios),
///           positionSlideIcon: 0.54,
///           enableLoop: true,
///           waveType: WaveType.liquidReveal,
///           liquidController: liquidController,
///           disableUserGesture: false,
///           ignoreUserGestureWhileAnimating: false,
///        ),
/// ```
class LiquidSwipeGallery extends StatefulWidget {
  /// Required a double value for swipe animation sensitivity
  ///
  /// Default : 400
  ///
  /// Lower the value faster the animation
  ///
  /// 100 would make animation much faster than current
  final double fullTransitionValue;

  /// If you want to change the initial page
  ///
  /// Required a int value which should be greater than or equals to 0 and less then the pages length other wise exception will be thrown.
  final int initialPage;

  /// Required a Widget that will be visible only if [enableSlideIcon] is set to true
  ///
  /// If not provided and [enableSlideIcon] is set [true], `Icon(Icons.arrow_back_ios)` this will be used by default
  final Widget? slideIconWidget;

  /// Required a double value ranges from 0.0 - 1.0
  ///
  /// -1.0 represents the 0% of height of the canvas and 100% for 1.0, similarly 0.0 represents vertical centre
  final double positionSlideIcon;

  /// Required a bool value in order to make the swipe in loop mode or not, i.e., to repeat them or not after reaching last page.
  final bool enableLoop;

  ///Required a [LiquidController] object for some magic methods
  final LiquidController? liquidController;

  ///Type of Wave you want, its a enum, you might have to import helpers.dart
  final WaveType waveType;

  ///see [OnPageChangeCallback]
  final OnPageChangeCallback? onPageChangeCallback;

  ///see [CurrentUpdateTypeCallback]
  final CurrentUpdateTypeCallback? currentUpdateTypeCallback;

  ///see [SlidePercentCallback]
  final SlidePercentCallback? slidePercentCallback;

  ///Required a bool value for disabling Fast Animation between pages
  ///
  /// If true fast swiping is disabled
  final bool ignoreUserGestureWhileAnimating;

  ///Required a bool value for disabling the user touch. you can still perform programmatic swipes
  ///
  ///see also for runtime changes : [LiquidController.shouldDisableGestures]
  final bool disableUserGesture;

  ///Required a bool to Enable or Disable the side reveal i.e., this clip area on the right side with 15.0px of reveal.
  final bool enableSideReveal;

  /// A Custom child delegate responsible for child creation in case of builder or fetcher in case of List.
  ///
  /// See also [LiquidSwipeChildDelegate]
  final LiquidSwipeChildDelegate liquidSwipeChildDelegate;

  //todo dokumentacja
  final double height;

  final double borderRadius;

  /// Constructor for LiquidSwipeGallery for predefined [pages]
  ///Required List of Widgets like Container/SizedBox
  ///
  /// sample page :
  ///
  /// ```dart
  ///     Container(
  ///      color: Colors.pink,
  ///      child: Column(
  ///       crossAxisAlignment: CrossAxisAlignment.center,
  ///       mainAxisSize: MainAxisSize.max,
  ///       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  ///       children: <Widget>[
  ///         Image.asset(
  ///           'assets/1.png',
  ///           fit: BoxFit.cover,
  ///         ),
  ///         Padding(
  ///           padding: EdgeInsets.all(20.0),
  ///         ),
  ///         Column(
  ///           children: <Widget>[
  ///             Text(
  ///               "Hi",
  ///               style: MyApp.style,
  ///             ),
  ///             Text(
  ///               "It's Me",
  ///               style: MyApp.style,
  ///             ),
  ///             Text(
  ///               "Sahdeep",
  ///               style: MyApp.style,
  ///             ),
  ///           ],
  ///         ),
  ///       ],
  ///     ),
  ///   ),
  /// ```
  ///
  /// You can just create a list using this type of widgets
  LiquidSwipeGallery({
    Key? key,
    required List<Widget> pages,
    this.fullTransitionValue = fullTransitionPx,
    this.initialPage = 0,
    this.slideIconWidget,
    this.positionSlideIcon = 0.8,
    this.enableLoop = true,
    this.liquidController,
    this.waveType = WaveType.liquidReveal,
    this.onPageChangeCallback,
    this.currentUpdateTypeCallback,
    this.slidePercentCallback,
    this.ignoreUserGestureWhileAnimating = false,
    this.disableUserGesture = false,
    this.enableSideReveal = false,
    this.height = 200,
    this.borderRadius = 20,
  })  : assert(initialPage >= 0 && initialPage < pages.length),
        assert(positionSlideIcon >= 0 && positionSlideIcon <= 1),
        assert(height > 0),
        assert(borderRadius >= 0),
        liquidSwipeChildDelegate = LiquidSwipePagesChildDelegate(pages),
        super(key: key);

  ///A builder constructor with same fields but with [itemBuilder]
  ///Sample itembuilder :
  ///
  ///               itemCount: data.length,
  ///               itemBuilder: (context, index){
  ///                 return Container(
  ///                   color: data[index].color,
  ///                   child: Column(
  ///                     crossAxisAlignment: CrossAxisAlignment.center,
  ///                     mainAxisSize: MainAxisSize.max,
  ///                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  ///                     children: <Widget>[
  ///                       Image.asset(
  ///                         data[index].image,
  ///                         fit: BoxFit.cover,
  ///                       ),
  ///                       Padding(
  ///                         padding: EdgeInsets.all(20.0),
  ///                       ),
  ///                       Column(
  ///                         children: <Widget>[
  ///                           Text(
  ///                             data[index].text1,
  ///                             style: WithPages.style,
  ///                           ),
  ///                           Text(
  ///                             data[index].text2,
  ///                             style: WithPages.style,
  ///                           ),
  ///                           Text(
  ///                             data[index].text3,
  ///                             style: WithPages.style,
  ///                           ),
  ///                         ],
  ///                       ),
  ///                     ],
  ///                   ),
  ///                 );
  ///               },
  ///
  /// See Example for complete reference.
  LiquidSwipeGallery.builder({
    Key? key,
    required IndexedWidgetBuilder itemBuilder,
    required int itemCount,
    this.fullTransitionValue = fullTransitionPx,
    this.initialPage = 0,
    this.slideIconWidget,
    this.positionSlideIcon = 0.8,
    this.enableLoop = true,
    this.liquidController,
    this.waveType = WaveType.liquidReveal,
    this.onPageChangeCallback,
    this.currentUpdateTypeCallback,
    this.slidePercentCallback,
    this.ignoreUserGestureWhileAnimating = false,
    this.disableUserGesture = false,
    this.enableSideReveal = false,
    this.height = 200,
    this.borderRadius = 20,
  })  : assert(itemCount > 0),
        assert(initialPage >= 0 && initialPage < itemCount),
        assert(positionSlideIcon >= 0 && positionSlideIcon <= 1),
        assert(height > 0),
        assert(borderRadius >= 0),
        liquidSwipeChildDelegate =
            LiquidSwipeBuilderChildDelegate(itemBuilder, itemCount),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _LiquidSwipeGalleryState();
}

class _LiquidSwipeGalleryState extends State<LiquidSwipeGallery>
    with TickerProviderStateMixin {
  late LiquidController liquidController;

  @override
  void initState() {
    liquidController = widget.liquidController ?? LiquidController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            Positioned.fill(
              child: ChangeNotifierProvider<LiquidProvider>(
                create: (BuildContext context) {
                  return LiquidProvider(
                    initialPage: widget.initialPage,
                    loop: widget.enableLoop,
                    length: widget.liquidSwipeChildDelegate.itemCount(),
                    vsync: this,
                    slideIcon: widget.positionSlideIcon,
                    currentUpdateTypeCallback: widget.currentUpdateTypeCallback,
                    slidePercentCallback: widget.slidePercentCallback,
                    onPageChangeCallback: widget.onPageChangeCallback,
                    disableGesture: widget.disableUserGesture,
                    enableSideReveal: widget.enableSideReveal,
                  );
                },
                child: Consumer(builder:
                    (BuildContext context, LiquidProvider notifier, _) {
                  liquidController.setContext(context);
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      notifier.slideDirection == SlideDirection.leftToRight
                          ? widget.liquidSwipeChildDelegate.getChildAtIndex(
                              context, notifier.activePageIndex)
                          : widget.liquidSwipeChildDelegate
                              .getChildAtIndex(context, notifier.nextPageIndex),
                      //Pages
                      PageReveal(
                        //next page reveal
                        horizontalReveal: notifier.slidePercentHor,
                        slideDirection: notifier.slideDirection,
                        iconSize: notifier.iconSize,
                        waveType: widget.waveType,
                        verticalReveal: notifier.slidePercentVer,
                        enableSideReveal: notifier.enableSideReveal,
                        child: notifier.slideDirection ==
                                SlideDirection.leftToRight
                            ? widget.liquidSwipeChildDelegate.getChildAtIndex(
                                context, notifier.nextPageIndex)
                            : widget.liquidSwipeChildDelegate.getChildAtIndex(
                                context, notifier.activePageIndex),
                      ),
                      PageDragger(
                        //Used for gesture control
                        fullTransitionPX: widget.fullTransitionValue,
                        slideIconWidget: widget.slideIconWidget,
                        iconPosition: widget.positionSlideIcon,
                        ignoreUserGestureWhileAnimating:
                            widget.ignoreUserGestureWhileAnimating,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
