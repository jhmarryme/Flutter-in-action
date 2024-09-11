import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

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
}

final Uuid uuid = Uuid();
final _router = GoRouter(
  initialLocation: '/index',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/index',
          builder: (context, state) => PageIndex(),
        ),
        GoRoute(
          path: '/pageA',
          builder: (context, state) => PageA(),
        ),
        GoRoute(
          path: '/pageB',
          builder: (context, state) => PageB(),
        ),
        GoRoute(
          path: '/pageC',
          builder: (context, state) => PageC(),
        ),
      ],
    ),
    GoRoute(
      path: '/pageD',
      builder: (context, state) => PageC(),
    )
  ],
);

final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({required this.child});

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  final Map<String, String> tabs = {};
  TabController? _tabController;
  List<Widget> tabPages = [];
  String? selectedTabId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 0);
  }

  void _addOrSwitchTab(String title) {
    String existingTabId = tabs.entries
        .firstWhere(
          (entry) => entry.value == title,
          orElse: () => MapEntry('', ''),
        )
        .key;

    if (existingTabId.isNotEmpty) {
      // 已经加载，切换到该Tab页
      setState(() {
        selectedTabId = existingTabId;
        _tabController!.index = tabs.keys.toList().indexOf(existingTabId);
      });
    } else {
      // 创建新Tab页
      String newId = uuid.v4();
      setState(() {
        tabs[newId] = title;
        tabPages.add(_buildTabPage(title));
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

  Widget _buildTabPage(String title) {
    switch (title) {
      case 'Page A':
        return PageA();
      case 'Page B':
        return PageB();
      case 'Page index':
        return PageIndex();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => GoRouter.of(context).go("/pageC"),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedTabId == null
                ? 0
                : tabs.keys.toList().indexOf(selectedTabId!),
            onDestinationSelected: (index) {
              if (index == 0) {
                _addOrSwitchTab('Page index');
              } else if (index == 1) {
                _addOrSwitchTab('Page A');
              } else if (index == 2) {
                _addOrSwitchTab('Page B');
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
                if (tabs.isNotEmpty)
                  TabBar(
                    controller: _tabController,
                    tabs: tabs.values.map((tab) => Tab(text: tab)).toList(),
                    onTap: (index) {
                      setState(() {
                        selectedTabId = tabs.keys.elementAt(index);
                      });
                    },
                  ),
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

class PageIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Page index')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            GoRouter.of(context).push('/pageD');
          },
          child: Text('Go to Page D'),
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
            context.push('/pageC');
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
            context.go('/pageD');
          },
          child: Text('Go to Page D'),
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
