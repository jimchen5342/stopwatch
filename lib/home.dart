import 'package:flutter/material.dart';
import 'package:myapp/stopwatch/stopwatchList.dart';
import 'package:myapp/train/trainList.dart';
import 'package:myapp/counting/counting.dart';
// import 'package:myapp/countdown/countdownList.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:myapp/system/module.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

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
      checkAndRequestBatteryOptimization(context);
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
    Counting(), // 計次，還沒想好怎麼做 UI，先放在這裡；2026-04-03
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
        // BottomNavigationBarItem( // 計次，還沒想好怎麼做 UI，先放在這裡；2026-04-03
        //   icon: Icon(Icons.list_alt_sharp),
        //   label: '計次', 
        // ),
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

Future<void> checkAndRequestBatteryOptimization(BuildContext context) async {

  // 1. 檢查目前是否已經「忽略電池最佳化」（即不受限制）
  var status = await Permission.ignoreBatteryOptimizations.status;
  
  if (status.isDenied) {
    // 2. 顯示對話框告知用戶原因（Android 要求必須先向用戶說明）
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('需要關閉電池最佳化'),
        content: const Text('為了讓語音播報在背景不被中斷，請將此 App 的電池設定改為「不受限制」。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('去設定')),
        ],
      ),
    );

    if (confirm == true) {
      // 3. 使用 Android Intent 跳轉至電池最佳化列表
      // 使用 ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS 導向設定頁面
      const intent = AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    }
  }
}