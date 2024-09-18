import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_go_router_dynamic_tab/dynamic_tab/src/dynamic_tab_controller.dart';
import 'package:provider/provider.dart';

import 'dynamic_tab_data.dart';

/// Dynamic Tabs.
class DynamicTabBarWidget extends TabBar {
  final Function(TabController) onTabControllerUpdated;
  final Function(int?)? onTabChanged;

  final DynamicTabController dynamicTabController;

  /// Defines where the Tab indicator animation moves to when new Tab is added.
  ///
  /// TabData contains two states at the moment [IDOL] and [LAST]
  ///
  final MoveToTab? onAddTabMoveTo;

  /// The back icon of the TabBar when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default back icon is used.
  ///
  /// If [isScrollable] is false, this property is ignored.
  final Widget? backIcon;

  /// The forward icon of the TabBar when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default forward icon is used.
  ///
  /// If [isScrollable] is false, this property is ignored.
  final Widget? nextIcon;

  /// The showBackIcon property of DynamicTabBarWidget is used when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default value is [true].
  ///
  /// If [isScrollable] is false, this property is ignored.
  final bool? showBackIcon;

  /// The showNextIcon property of DynamicTabBarWidget is used when [isScrollable] is true.
  ///
  /// If this parameter is null, then the default value is [true].
  ///
  /// If [isScrollable] is false, this property is ignored.
  final bool? showNextIcon;

  /// The leading property is used to add custom leading widget in TabBar.
  ///
  /// By default [leading] widget is null.
  ///
  final Widget? leading;

  /// The leading property is used to add custom trailing widget in TabBar.
  ///
  /// By default [trailing] widget is null.
  ///
  final Widget? trailing;

  /// The physics property is used to set the physics of TabBarView.
  final ScrollPhysics? physicsTabBarView;

  /// The dragStartBehavior property is used to set the dragStartBehavior of TabBarView.
  ///
  /// By default [dragStartBehavior] is DragStartBehavior.start.
  final DragStartBehavior dragStartBehaviorTabBarView;

  /// The clipBehavior property is used to set the clipBehavior of TabBarView.
  ///
  /// By default [clipBehavior] is Clip.hardEdge.
  final double viewportFractionTabBarView;

  /// The clipBehavior property is used to set the clipBehavior of TabBarView.
  ///
  /// By default [clipBehavior] is Clip.hardEdge.
  final Clip clipBehaviorTabBarView;

  DynamicTabBarWidget({
    super.key,
    required this.dynamicTabController,
    required this.onTabControllerUpdated,
    this.onTabChanged,
    this.onAddTabMoveTo,
    super.isScrollable,
    this.backIcon,
    this.nextIcon,
    this.showBackIcon = true,
    this.showNextIcon = true,
    this.leading,
    this.trailing,
    // Default Tab properties :---------------------------------------
    super.padding,
    super.indicatorColor,
    super.automaticIndicatorColorAdjustment = true,
    super.indicatorWeight = 2.0,
    super.indicatorPadding = EdgeInsets.zero,
    super.indicator,
    super.indicatorSize,
    super.dividerColor,
    super.dividerHeight,
    super.labelColor,
    super.labelStyle,
    super.labelPadding,
    super.unselectedLabelColor,
    super.unselectedLabelStyle,
    super.dragStartBehavior = DragStartBehavior.start,
    super.overlayColor,
    super.mouseCursor,
    super.enableFeedback,
    super.onTap,
    super.physics,
    super.splashFactory,
    super.splashBorderRadius,
    super.tabAlignment,
    // Default TabBarView properties :---------------------------------------
    this.physicsTabBarView,
    this.dragStartBehaviorTabBarView = DragStartBehavior.start,
    this.viewportFractionTabBarView = 1.0,
    this.clipBehaviorTabBarView = Clip.hardEdge,
  }) : super(tabs: []);

  @override
  // ignore: library_private_types_in_public_api
  _DynamicTabBarWidgetState createState() => _DynamicTabBarWidgetState();
}

class _DynamicTabBarWidgetState extends State<DynamicTabBarWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    widget.dynamicTabController.initialTabController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    widget.dynamicTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => widget.dynamicTabController,
      child: Consumer<DynamicTabController>(
        builder: (context, dynamicTabController, child) {
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: DefaultTabController(
              length: dynamicTabController.dynamicTabs.length,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      if (widget.leading != null) widget.leading!,
                      if (widget.isScrollable == true &&
                          widget.showBackIcon == true)
                        IconButton(
                          icon: widget.backIcon ??
                              const Icon(
                                Icons.arrow_back_ios,
                              ),
                          onPressed: dynamicTabController.moveToPreviousTab,
                        ),
                      Expanded(
                        child: TabBar(
                          isScrollable: widget.isScrollable,
                          controller: dynamicTabController.tabController,
                          tabs: dynamicTabController.dynamicTabs.map((tab) {
                            return Tab(
                              child: Stack(
                                children: [
                                  // Tab title positioned on the left
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(right: 30.0),
                                      // Give padding to prevent overlap with the close button
                                      child: tab.title,
                                    ),
                                  ),
                                  // Close button positioned on the right
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: ClipRect(
                                      child: SizedBox(
                                        width: 24.0,
                                        height: 24.0,
                                        // Fixed size for the close button
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              size: 16.0),
                                          // Adjust icon size
                                          onPressed: () => dynamicTabController
                                              .removeTabByTabDataId(tab.id),
                                          padding: EdgeInsets.zero,
                                          // Remove default padding
                                          constraints:
                                              BoxConstraints(), // Remove default constraints
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          // Default Tab properties :---------------------------------------
                          padding: widget.padding,
                          indicatorColor: widget.indicatorColor,
                          automaticIndicatorColorAdjustment:
                              widget.automaticIndicatorColorAdjustment,
                          indicatorWeight: widget.indicatorWeight,
                          indicatorPadding: widget.indicatorPadding,
                          indicator: widget.indicator,
                          indicatorSize: widget.indicatorSize,
                          dividerColor: widget.dividerColor,
                          dividerHeight: widget.dividerHeight,
                          labelColor: widget.labelColor,
                          labelStyle: widget.labelStyle,
                          labelPadding: widget.labelPadding,
                          unselectedLabelColor: widget.unselectedLabelColor,
                          unselectedLabelStyle: widget.unselectedLabelStyle,
                          dragStartBehavior: widget.dragStartBehavior,
                          overlayColor: widget.overlayColor,
                          mouseCursor: widget.mouseCursor,
                          enableFeedback: widget.enableFeedback,
                          onTap: widget.onTap,
                          physics: widget.physics,
                          splashFactory: widget.splashFactory,
                          splashBorderRadius: widget.splashBorderRadius,
                          tabAlignment: widget.tabAlignment,
                        ),
                      ),
                      if (widget.isScrollable == true &&
                          widget.showNextIcon == true)
                        IconButton(
                          icon: widget.nextIcon ??
                              const Icon(
                                Icons.arrow_forward_ios,
                              ),
                          onPressed: dynamicTabController.moveToNextTab,
                        ),
                      if (widget.trailing != null) widget.trailing!,
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: dynamicTabController.tabController,
                      physics: widget.physicsTabBarView,
                      dragStartBehavior: widget.dragStartBehaviorTabBarView,
                      viewportFraction: widget.viewportFractionTabBarView,
                      clipBehavior: widget.clipBehaviorTabBarView,
                      children: dynamicTabController.dynamicTabs
                          .map((tab) => tab.content)
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
