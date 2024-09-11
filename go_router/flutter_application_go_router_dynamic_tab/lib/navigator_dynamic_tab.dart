import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  final Uuid uuid = Uuid();
  Map<String, TabInfo> tabs = {}; // 保存加载的tab信息
  TabController? _tabController;
  List<Widget> tabPages = []; // 用于存储每个tab的内容
  String? selectedTabId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 0);
  }

  void _addOrSwitchTab(String title, Widget content) {
    var existingTab = tabs.entries.firstWhere(
      (entry) => entry.value.title == title,
      orElse: () =>
          MapEntry('', TabInfo(id: '', title: '', content: Container())),
    );

    if (existingTab.key.isNotEmpty) {
      // 已经加载，切换到该Tab页
      setState(() {
        selectedTabId = existingTab.key;
        _tabController!.index = tabs.keys.toList().indexOf(existingTab.key);
      });
    } else {
      // 创建新Tab页
      String newId = uuid.v4();
      setState(() {
        tabs[newId] = TabInfo(
          id: newId,
          title: title,
          content: TabNavigator(id: newId, rootPage: content),
        );
        tabPages.add(TabNavigator(id: newId, rootPage: content));
        _tabController = TabController(
            vsync: this, length: tabs.length, initialIndex: tabs.length - 1);
        selectedTabId = newId;
      });
    }
  }

  void _closeTab(String id) {
    int closingTabIndex = tabs.keys.toList().indexOf(id);
    setState(() {
      tabs.remove(id);
      tabPages.removeAt(closingTabIndex);
      _tabController = TabController(vsync: this, length: tabs.length);
      if (tabs.isNotEmpty) {
        selectedTabId = tabs.keys.first;
      } else {
        selectedTabId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 左侧菜单栏
          NavigationRail(
            selectedIndex: selectedTabId == null
                ? 0
                : tabs.keys.toList().indexOf(selectedTabId!),
            onDestinationSelected: (index) {
              if (index == 0) {
                _addOrSwitchTab('Page index', PageIndex());
              } else if (index == 1) {
                _addOrSwitchTab('Page A', PageA());
              } else if (index == 2) {
                _addOrSwitchTab('Page B', PageB());
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('Open Page Index'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('Open Page A'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add),
                label: Text('Open Page B'),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                // 动态 Tab 页标签栏
                if (tabs.isNotEmpty)
                  TabBar(
                    controller: _tabController,
                    tabs:
                        tabs.values.map((tab) => Tab(text: tab.title)).toList(),
                    onTap: (index) {
                      setState(() {
                        selectedTabId = tabs.keys.elementAt(index);
                      });
                    },
                  ),
                // Tab 页内容切换
                if (tabs.isNotEmpty)
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: tabPages,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabInfo {
  final String id;
  final String title;
  final Widget content;

  TabInfo({required this.id, required this.title, required this.content});
}

class TabNavigator extends StatelessWidget {
  final String id;
  final Widget rootPage;

  const TabNavigator({required this.id, required this.rootPage});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        Widget page = rootPage;
        if (settings.name == '/pageA') {
          page = PageA();
        }
        if (settings.name == '/pageB') {
          page = PageB();
        }
        if (settings.name == '/pageC') {
          page = PageC();
        }
        if (settings.name == '/pageIndex') {
          page = PageIndex();
        }
        return MaterialPageRoute(builder: (context) => page);
      },
    );
  }
}

class PageIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page index')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/pageA');
          },
          child: Text('Go to Page A'),
        ),
      ),
    );
  }
}

class PageA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page A')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/pageC');
          },
          child: Text('Go to Page C'),
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page B')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/pageIndex');
          },
          child: Text('Go to Page pageIndex'),
        ),
      ),
    );
  }
}

class PageC extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page C')),
      body: Center(child: Text('This is Page C')),
    );
  }
}
