import 'package:flutter/material.dart';
import 'package:myapp/stopwatch/stopwatchList.dart';
import 'package:myapp/countdown/countdownList.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:myapp/system/module.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0; // 用於追蹤目前選中的索引
  String version = " ";
  StorageManager storage = StorageManager();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;

      var index = storage.getInt("bottomNavigationIndex");
      if (index is int) {
        _selectedIndex = index;
      }
      setState(() {
        Timer(Duration(seconds: 2), () {
          setState(() {});
          version = "";
        });
      });
    });
  }

  // 準備要顯示在不同分頁的 Widget 列表
  // 這些可以是任何你想要顯示的 Widget，例如不同的頁面或畫面
  static const List<Widget> _widgetOptions = <Widget>[
    StopWatchList(), // 碼錶
    CountDownList(),
  ];

  // 當點擊 BottomNavigationBarItem 時調用的函數
  void _onItemTapped(int index) {
    storage.setInt("bottomNavigationIndex", index);
    setState(() {
      _selectedIndex = index; // 更新選中的索引，觸發 UI 重建
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          version.isNotEmpty
              ? _versiion()
              : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: version.isNotEmpty ? null : bottom(),
    );
  }

  Widget _versiion() {
    return Center(
      child: Text(
        version,
        style: TextStyle(fontSize: 30, color: HexColor.fromHex('#C01921')),
      ),
    );
  }

  Widget bottom() {
    return (BottomNavigationBar(
      // type: BottomNavigationBarType.fixed, // Fixed
      backgroundColor: SysColor.primary, // <-- This works for fixed
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time_sharp),
          label: '碼錶',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.alarm), label: '計時器'),
      ],
      currentIndex: _selectedIndex, // 目前選中的項目索引
      selectedItemColor: Colors.white, // 選中項目的顏色
      unselectedItemColor: Colors.grey, // 未選中項目的顏色
      onTap: _onItemTapped, // 點擊項目時的回調函數
      // type: BottomNavigationBarType.fixed, // 當項目多於3個時，可以設為 shifting 或 fixed
    ));
  }
}
