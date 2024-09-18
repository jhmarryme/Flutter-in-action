import 'package:flutter/material.dart';

import 'dynamic_tab_data.dart';

class DynamicTabController with ChangeNotifier {
  /// List of Tabs.
  ///
  /// TabData contains [id] of the tab and the title which is extension of [TabBar] header.
  /// and the [content] is the extension of [TabBarView] so all the page content is displayed in this section
  ///
  ///
  final List<TabData> dynamicTabs;
  late TabController tabController;
  late int activeTab;
  late TickerProvider vsync;
  final Function(TabController)? onTabControllerUpdated;
  final Function(int, TabData)? onTabChanged;
  final MoveToTab? onAddTabMoveTo;

  DynamicTabController({
    required this.dynamicTabs,
    this.onAddTabMoveTo,
    this.onTabControllerUpdated,
    this.onTabChanged,
    int initialIndex = 0,
  }) {
    activeTab = initialIndex >= dynamicTabs.length ? initialIndex : 0;
  }

  bool addTab(TabData tabData) {
    if (dynamicTabs.indexWhere((element) => element.id == tabData.id) >= 0) {
      return false;
    }
    dynamicTabs.add(
      tabData,
    );
    updateTabController(initialIndex: dynamicTabs.length - 1);
    return true;
  }

  void removeTab(int index) {
    if (dynamicTabs.isNotEmpty && index < dynamicTabs.length) {
      int onRemoveInitialIndex =
          calcOnRemoveInitialIndex(index, moveToTab: onAddTabMoveTo);
      debugPrint(
          "after remove tab, the onRemoveInitialIndex is $onRemoveInitialIndex");
      dynamicTabs.removeAt(index);
      updateTabController(initialIndex: onRemoveInitialIndex);
    }
  }

  void removeTabByTabDataId(int tabDataIndex) {
    if (dynamicTabs.isNotEmpty) {
      var removeIndex =
          dynamicTabs.indexWhere((element) => element.id == tabDataIndex);
      if (removeIndex >= 0) {
        removeTab(removeIndex);
      }
    }
  }

  void moveToNextTab() {
    if (tabController.index + 1 < tabController.length) {
      tabController.animateTo(tabController.index + 1);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't move forward"),
      // ));
    }
    notifyListeners();
  }

  void moveToPreviousTab() {
    if (tabController.index > 0) {
      tabController.animateTo(tabController.index - 1);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text("Can't go back"),
      // ));
    }
    notifyListeners();
  }

  int getActiveTab() {
    // when there are No tabs
    if (activeTab == 0 && dynamicTabs.isEmpty) {
      return 0;
    }
    if (activeTab == dynamicTabs.length) {
      return dynamicTabs.length - 1;
    }
    if (activeTab < dynamicTabs.length) {
      return activeTab;
    }
    return dynamicTabs.length;
  }

  // ignore: body_might_complete_normally_nullable
  int calcOnRemoveInitialIndex(int removeIndex,
      {MoveToTab? moveToTab = MoveToTab.next}) {
    if (activeTab == removeIndex) {
      bool isLast = activeTab == dynamicTabs.length - 1;
      switch (moveToTab) {
        case MoveToTab.next:
          return isLast ? activeTab - 1 : activeTab;
        case MoveToTab.previous:
          return activeTab - 1;
        case MoveToTab.first:
          return 0;
        case MoveToTab.last:
          return dynamicTabs.length - 2;
        // case MoveToTab.idol:
        //   return null;
        case null:
          return dynamicTabs.length - 2;
      }
    }
    return activeTab > removeIndex ? activeTab - 1 : activeTab;
  }

  void _handleTabChange() {
    activeTab =
        tabController.index >= dynamicTabs.length ? 0 : tabController.index;
    if (tabController.indexIsChanging) {
      onTabChanged?.call(tabController.index, dynamicTabs[activeTab]);
    }
    notifyListeners();
  }

  void initialTabController(
      {required TickerProvider vsync, int initialIndex = 0}) {
    this.vsync = vsync;
    tabController = TabController(
      length: dynamicTabs.length,
      vsync: vsync,
      initialIndex: initialIndex,
    )..addListener(_handleTabChange);
    updateActiveTab(initialIndex);
    notifyListeners();
  }

  void updateTabController({TickerProvider? vsync, int initialIndex = 0}) {
    debugPrint("ready to updateTabController, initialIndex is $initialIndex");
    updateActiveTab(initialIndex);
    tabController = TabController(
      length: dynamicTabs.length,
      vsync: vsync ?? this.vsync,
      initialIndex: activeTab,
    )..addListener(_handleTabChange);
    notifyListeners();
  }

  void updateActiveTab(int activeTab) {
    if (activeTab < 0 || activeTab >= dynamicTabs.length) {
      activeTab = 0;
    }
    this.activeTab = activeTab;
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
