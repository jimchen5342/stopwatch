import 'package:flutter/material.dart';
import 'package:myapp/stopwatch/stopwatchList.dart';
import 'package:myapp/train/trainList.dart';
// import 'package:myapp/countdown/countdownList.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:myapp/system/module.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String TAG = "stopwatchHome";
  int _selectedIndex = 0; // 用於追蹤目前選中的索引
  String version = " ";
  StorageManager storage = StorageManager();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      version = packageInfo.version;
      setState(() {});

      if (await requestPostNotificationsPermission() == true) {
        var index = storage.getInt("bottomNavigationIndex");
        if (index is int) {
          _selectedIndex = index;
        }
        Timer(Duration(seconds: 2), () {
          setState(() {});
          version = "";
        });
      }
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    StopWatchList(), // 碼錶
    TrainList(), // 訓練
    // CountDownList(),
  ];

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
          icon: Icon(Icons.access_time_filled_rounded),
          label: '碼錶清單',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt_sharp),
          label: '訓練清單',
        ),
        // BottomNavigationBarItem(icon: Icon(Icons.alarm), label: '計時器'),
      ],
      currentIndex: _selectedIndex, // 目前選中的項目索引
      selectedItemColor: Colors.white, // 選中項目的顏色
      unselectedItemColor: Colors.grey, // 未選中項目的顏色
      onTap: _onItemTapped, // 點擊項目時的回調函數
      // type: BottomNavigationBarType.fixed, // 當項目多於3個時，可以設為 shifting 或 fixed
    ));
  }

  Future<bool> requestPostNotificationsPermission() async {
    bool b = false;
    var status = await Permission.notification.status;
    // debugPrint("$TAG requestPostNotificationsPermission1: $status");
    if (status.isDenied) {
      // 權限被拒絕，發出請求
      status = await Permission.notification.request();
      // debugPrint("$TAG requestPostNotificationsPermission2: $status");
      if (status.isGranted) {
        b = true;
      }
    } else if (status.isGranted) {
      b = true;
    }
    return b;
  }

  Future<bool> requestStoragePermission() async {
    // 沒有效，2025-07-31
    bool b = false;
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
      if (status.isGranted) {
        b = true;
      }
    } else if (status.isGranted) {
      b = true;
    }
    return b;
  }
}
