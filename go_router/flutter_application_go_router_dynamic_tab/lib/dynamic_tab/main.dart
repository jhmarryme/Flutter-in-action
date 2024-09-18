import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_go_router_dynamic_tab/dynamic_tab/src/dynamic_tab_controller.dart';

import 'dynamic_tab.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic TabBar Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Example for Dynamic TabBar'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late DynamicTabController dynamicTabController;
  bool isScrollable = false;
  bool showNextIcon = true;
  bool showBackIcon = true;

  // Leading icon
  Widget? leading;

  // Trailing icon
  Widget? trailing;

  // Sample data for tabs
  List<TabData> tabs = [
    TabData(
      id: 1,
      routeName: 'Tab 1',
      title: const Tab(
        child: Text('Tab 1'),
      ),
      content: const Center(child: Text('Content for Tab 1')),
    ),
    TabData(
      id: 2,
      routeName: 'Tab 2',
      title: const Tab(
        child: Text('Tab 2'),
      ),
      content: const Center(child: Text('Content for Tab 2')),
    ),
    // Add more tabs as needed
  ];

  @override
  void initState() {
    dynamicTabController =
        DynamicTabController(dynamicTabs: tabs, onAddTabMoveTo: MoveToTab.next);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: addTab,
                  child: const Text('Add Tab'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () =>
                      dynamicTabController.removeTab(tabs.length - 1),
                  child: const Text('Remove Last Tab'),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('isScrollable'),
                    Switch.adaptive(
                      value: isScrollable,
                      onChanged: (bool val) {
                        // setState(() {
                        //   isScrollable = !isScrollable;
                        // });
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('showBackIcon'),
                    Switch.adaptive(
                      value: showBackIcon,
                      onChanged: (bool val) {
                        // setState(() {
                        //   showBackIcon = !showBackIcon;
                        // });
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('showNextIcon'),
                    Switch.adaptive(
                      value: showNextIcon,
                      onChanged: (bool val) {
                        // setState(() {
                        //   showNextIcon = !showNextIcon;
                        // });
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 22),
                const SizedBox(width: 12),
              ],
            ),
          ),
          Expanded(
            child: DynamicTabBarWidget(
              dynamicTabController: dynamicTabController,
              // optional properties :-----------------------------
              isScrollable: true,
              onTabControllerUpdated: (controller) {
                debugPrint("onTabControllerUpdated");
              },
              onTabChanged: (index) {
                debugPrint("Tab changed: $index");
              },
              // backIcon: Icon(Icons.keyboard_double_arrow_left),
              // nextIcon: Icon(Icons.keyboard_double_arrow_right),
              showBackIcon: showBackIcon,
              showNextIcon: showNextIcon,
              leading: leading,
              trailing: trailing,
            ),
          ),
        ],
      ),
    );
  }

  void addTab() {
    var tabNumber = Random.secure().nextInt(99999199);

    var result = dynamicTabController.addTab(TabData(
      id: tabNumber,
      routeName: 'Tab $tabNumber',
      title: SizedBox(
        width: 130,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Tab $tabNumber 1111111111111xxxxxxxxxx1111111111111111111111111111',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                size: 15,
              ),
              onPressed: () {
                dynamicTabController.removeTabByTabDataId(tabNumber);
              },
              color: Colors.black54,
            ),
          ],
        ),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Dynamic Tab $tabNumber'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () =>
                dynamicTabController.removeTabByTabDataId(tabNumber),
            child: const Text('Remove this Tab'),
          ),
        ],
      ),
    ));
    debugPrint('addTab result: $result');
  }
}
