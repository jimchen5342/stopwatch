import 'package:flutter/material.dart';
import 'package:myapp/stopwatch.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // 用於追蹤目前選中的索引

  @override
  initState() {
    super.initState();

  }

  // 準備要顯示在不同分頁的 Widget 列表
  // 這些可以是任何你想要顯示的 Widget，例如不同的頁面或畫面
  static const List<Widget> _widgetOptions = <Widget>[
    StopWatch(), // 碼錶
    Center(
      child: Text(
        '計時器，還沒寫',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
    )
    
  ];

  // 當點擊 BottomNavigationBarItem 時調用的函數
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 更新選中的索引，觸發 UI 重建
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          // type: BottomNavigationBarType.fixed, // Fixed 
          // backgroundColor: Colors.blue, // <-- This works for fixed
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_sharp),
              label: '碼錶',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_alarms_sharp),
              label: '計時器',
            ),
          ],
          currentIndex: _selectedIndex, // 目前選中的項目索引
          selectedItemColor: Colors.amber[800], // 選中項目的顏色
          unselectedItemColor: Colors.grey, // 未選中項目的顏色
          onTap: _onItemTapped, // 點擊項目時的回調函數
          // type: BottomNavigationBarType.fixed, // 當項目多於3個時，可以設為 shifting 或 fixed
        ),
    
    );
  }
}
