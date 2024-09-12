import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// chatGPT 4o 生成
/// 该类实现了基于 `go_router` 的动态多标签页导航结构，并结合 `TabBar` 和 `NavigationRail` 组件提供侧边栏和标签页的联动效果。
///
/// 主要功能：
/// 1. 通过 `go_router` 管理路由，实现页面导航；
/// 2. 使用 `TabController` 控制标签页，并动态添加、切换、删除标签；
/// 3. 通过 `NavigationRail` 实现左侧菜单栏，与标签页同步更新选中状态；
/// 4. 每个标签页有独立的 `Navigator`，保证每个页面的导航栈独立运行；
/// 5. 顶部的 `TabBar` 显示当前打开的页面标签，支持关闭不需要的标签页；
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Tab Navigation Demo',
      routerConfig: _router,
    );
  }
}

// 配置 GoRouter
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/page1',
          name: 'page1',
          builder: (context, state) => const Page1(),
        ),
        GoRoute(
          path: '/page2',
          name: 'page2',
          builder: (context, state) => const Page2(),
        ),
        GoRoute(
          path: '/page3',
          name: 'page3',
          builder: (context, state) => const Page3(),
        ),
      ],
    ),
  ],
);

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  List<String> tabs = ['Home']; // 初始默认打开 Home 标签
  Map<String, GlobalKey<NavigatorState>> tabNavigators = {};
  TabController? _tabController;
  int _selectedIndex = 0; // 左侧菜单栏选中的索引

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    // 监听 TabController 的变化，确保 TabBar 切换同步左侧菜单栏
    _tabController?.addListener(() {
      if (_tabController!.indexIsChanging) {
        // 更新菜单栏焦点
        setState(() {
          _selectedIndex = _tabController!.index;
        });

        // 路由监听：根据标签切换时触发路由跳转
        String currentTab = tabs[_tabController!.index];
        switch (currentTab) {
          case 'Home':
            context.go('/home');
            break;
          case 'Page 1':
            context.go('/page1');
            break;
          case 'Page 2':
            context.go('/page2');
            break;
          case 'Page 3':
            context.go('/page3');
            break;
        }
      }
    });
  }

  void _addTab(String name, int index) {
    if (!tabs.contains(name)) {
      setState(() {
        tabs.add(name);
        tabNavigators[name] = GlobalKey<NavigatorState>();
        _tabController = TabController(length: tabs.length, vsync: this);
        _tabController?.addListener(() {
          if (_tabController!.indexIsChanging) {
            setState(() {
              _selectedIndex = _tabController!.index;
            });
          }
        });
      });
    }
    setState(() {
      _selectedIndex = index;
    });
    _switchToTab(name);
  }

  void _switchToTab(String name) {
    int index = tabs.indexOf(name);
    if (index != -1) {
      _tabController?.animateTo(index);
      setState(() {
        // 同步更新左侧菜单栏的焦点
        _selectedIndex = index;
      });
    }
  }

  void _removeTab(int index) {
    setState(() {
      String tabName = tabs[index];
      tabs.removeAt(index);
      tabNavigators.remove(tabName);
      _tabController = TabController(length: tabs.length, vsync: this);
      _tabController?.addListener(() {
        if (_tabController!.indexIsChanging) {
          setState(() {
            _selectedIndex = _tabController!.index;
          });
        }
      });

      // 如果删除的是当前选中的 Tab，选中前一个
      if (index == _tabController!.index && tabs.isNotEmpty) {
        _tabController!.animateTo(_tabController!.index - 1);
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
            selectedIndex: _selectedIndex,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pageview),
                label: Text('Page 1'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pages),
                label: Text('Page 2'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.tab),
                label: Text('Page 3'),
              ),
            ],
            onDestinationSelected: (index) {
              switch (index) {
                case 0:
                  _addTab('Home', index);
                  break;
                case 1:
                  _addTab('Page 1', index);
                  break;
                case 2:
                  _addTab('Page 2', index);
                  break;
                case 3:
                  _addTab('Page 3', index);
                  break;
              }
            },
          ),

          // 右侧 Tab 栏和 TabView
          Expanded(
            child: Column(
              children: [
                // 顶部 Tab 栏
                if (tabs.isNotEmpty)
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: [
                      for (var i = 0; i < tabs.length; i++)
                        Tab(
                          child: Row(
                            children: [
                              Text(tabs[i]),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => _removeTab(i),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                // Tab 页内容，使用独立的 Navigator 管理每个 Tab 的路由栈
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: tabs.map((tab) {
                      return Navigator(
                        key: tabNavigators[tab], // 使用对应 Tab 的 Navigator Key
                        // [onGenerateRoute config]
                        onGenerateRoute: (RouteSettings settings) {
                          Widget page;
                          switch (tab) {
                            case 'Home':
                              page = const HomePage();
                              break;
                            case 'Page 1':
                              page = const Page1();
                              break;
                            case 'Page 2':
                              page = const Page2();
                              break;
                            case 'Page 3':
                              page = const Page3();
                              break;
                            default:
                              page = const HomePage();
                              break;
                          }
                          // Navigator.of(context).pushNamed('Page 2')
                          if (settings.name == 'Page 2') {
                            page = const Page2();
                          }
                          return MaterialPageRoute(
                            builder: (_) => page,
                            settings: settings,
                          );
                        },
                      );
                    }).toList(),
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

// 首页
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // 页面跳转到 Page 1, 直接push页面
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Page1()),
          );
        },
        child: const Text('Go to Page 1'),
      ),
    );
  }
}

// 页面1
class Page1 extends StatelessWidget {
  const Page1({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // 页面跳转到 Page 2
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const Page2()),
          // );
          // 这种方式必须在 [onGenerateRoute config] 中 通过settings.name处理
          Navigator.of(context).pushNamed("Page 2");
        },
        child: const Text('Go to Page 2'),
      ),
    );
  }
}

// 页面2
class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // 页面跳转到 Page 3
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Page3()),
          );
        },
        child: const Text('Go to Page 3'),
      ),
    );
  }
}

// 页面3
class Page3 extends StatelessWidget {
  const Page3({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('This is Page 3'),
    );
  }
}
