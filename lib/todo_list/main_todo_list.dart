import 'package:flutter/material.dart';
import 'package:bruno/bruno.dart';
import 'package:flutter/foundation.dart';

import 'mission_page.dart';
import 'my_page.dart';

void main() {
  // 初始化Bruno
  BrnInitializer.register(allThemeConfig: BrnAllThemeConfig(
    commonConfig: BrnCommonConfig(
      brandPrimary: Colors.blue,
    ),
  ));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Todo List'),
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
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const MissionPage(),
    const MyPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BrnBottomTabBar(
        currentIndex: _currentIndex,
        items: const [
          BrnBottomTabBarItem(icon: Icon(Icons.list), title: Text('Mission')),
          BrnBottomTabBarItem(icon: Icon(Icons.person), title: Text('My')),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}