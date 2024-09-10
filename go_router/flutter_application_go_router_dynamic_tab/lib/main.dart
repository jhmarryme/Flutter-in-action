import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart'; // 生成唯一ID

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => HomePage(),
          ),
          GoRoute(
            path: '/tabs/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TabPage(id: id);
            },
            routes: [
              GoRoute(
                path: 'pageC',
                builder: (context, state) => PageC(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({required this.child});

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final Uuid uuid = Uuid();
  Map<String, TabInfo> tabs = {}; // 保存加载的tab信息
  String? selectedTabId;

  void _addOrSwitchTab(String title) {
    // 检查该页面是否已经打开过
    var existingTab = tabs.entries.firstWhere(
      (entry) => entry.value.title == title,
      orElse: () => MapEntry('', TabInfo(id: '', title: '', route: '')),
    );

    if (existingTab.key.isNotEmpty) {
      // 如果已经加载，切换到该Tab页
      setState(() {
        selectedTabId = existingTab.key;
        GoRouter.of(context).go(existingTab.value.route);
      });
    } else {
      // 如果没有加载，创建新Tab页
      String newId = uuid.v4();
      setState(() {
        tabs[newId] = TabInfo(
          id: newId,
          title: title,
          route: '/tabs/$newId',
        );
        selectedTabId = newId;
        GoRouter.of(context).go('/tabs/$newId');
      });
    }
  }

  void _closeTab(String id) {
    setState(() {
      tabs.remove(id);
      if (tabs.isEmpty) {
        selectedTabId = null;
        GoRouter.of(context).go('/');
      } else {
        selectedTabId = tabs.keys.first;
        GoRouter.of(context).go(tabs[selectedTabId!]!.route);
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
                _addOrSwitchTab('Page A');
              } else if (index == 1) {
                _addOrSwitchTab('Page B');
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
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
                  TabBarWidget(
                    tabs: tabs.values.toList(),
                    selectedTabId: selectedTabId,
                    onTabSelected: (id) {
                      setState(() {
                        selectedTabId = id;
                        GoRouter.of(context).go(tabs[id]!.route);
                      });
                    },
                    onCloseTab: _closeTab,
                  ),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabBarWidget extends StatelessWidget {
  final List<TabInfo> tabs;
  final String? selectedTabId;
  final Function(String) onTabSelected;
  final Function(String) onCloseTab;

  const TabBarWidget({
    required this.tabs,
    required this.selectedTabId,
    required this.onTabSelected,
    required this.onCloseTab,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: tabs.map((tab) {
        return GestureDetector(
          onTap: () => onTabSelected(tab.id),
          child: Container(
            color: selectedTabId == tab.id ? Colors.blue : Colors.grey,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(tab.title),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => onCloseTab(tab.id),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class TabInfo {
  final String id;
  final String title;
  final String route;

  TabInfo({required this.id, required this.title, required this.route});
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Select a page from the menu'));
  }
}

class TabPage extends StatelessWidget {
  final String id;

  const TabPage({required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page with ID $id')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            GoRouter.of(context).go('/tabs/$id/pageC');
          },
          child: Text('Go to Page C'),
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
