import 'package:flutter/material.dart';
import "package:myapp/home.dart";
import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'dart:async';
import 'dart:ui';
import 'package:myapp/system/module.dart';

String TAG = "stopwatchMain";
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget with WidgetsBindingObserver {
  final StorageManager storage = StorageManager();
  final FlutterBackgroundService _service = FlutterBackgroundService();

  MyApp({super.key}) {
    WidgetsFlutterBinding.ensureInitialized();
    initializeService();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await storage.initStorage();
      // storage.clear();
    });
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // debugPrint("stopWatch: didChangeAppLifecycleState: $state");
    if (AppLifecycleState.detached == state) {
      // APP 被銷毀、釋放
      bool isRunning = await _service.isRunning();
      debugPrint(
        "$TAG, didChangeAppLifecycleState: $state, isRunning: $isRunning",
      );
      if (isRunning) {
        _service.invoke("stop");
      }
    } else if (AppLifecycleState.paused == state) {}
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SysColor.primary),
      ),
      home: const Home(),
    );
  }
}

// 初始化背景服務的函數
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // 設定 Android 前景服務的選項
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // 當服務啟動時執行的函數
      onStart: onStart,
      autoStart: false, // 我們將手動啟動
      isForegroundMode: false,
      // 前景通知的設定
      // notificationChannelId: 'my_foreground',
      // initialNotificationTitle: '背景碼錶',
      // initialNotificationContent: '正在初始化...',
      // foregroundServiceNotificationId: 888,
    ),
    // iOS 設定 (此範例主要針對 Android)
    iosConfiguration: IosConfiguration(
      autoStart: false, // 我們將手動啟動
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

// iOS 背景執行的回調函數 (可選)
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

// 背景服務啟動時執行的函數
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // 允許 Dart VM 在背景執行
  DartPluginRegistrant.ensureInitialized();

  // 如果服務是 AndroidForegroundService 的實例，則監聽事件
  if (service is AndroidServiceInstance) {
    // 監聽 'setAsForeground' 事件，將服務設為前景
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    // 監聽 'setAsBackground' 事件，將服務設為背景
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  int seconds = 0, timestamp = 0;
  Timer? timer;
  void timerCount() {
    debugPrint("$TAG timerCount");
    seconds = 0;

    timer = Timer.periodic(const Duration(seconds: 1), (_timer) async {
      debugPrint("$TAG: seconds: $seconds");
      timer = _timer;
      seconds++;
      // 更新前景通知內容
      // if (service is AndroidServiceInstance) {
      //   // 如果你想在通知中顯示碼錶，可以在這裡更新
      //   service.setForegroundNotificationInfo(
      //     title: "背景碼錶執行中",
      //     content: "已過時間：$seconds 秒",
      //   );
      // }

      // 將碼錶更新發送到前景 UI
      service.invoke('update', {"seconds": seconds, "timestamp": timestamp});
      // if (seconds > 60) timer?.cancel();
    });
  }

  service.on("start").listen((event) async {
    if (event?.containsKey("timestamp") != null) {
      timestamp = event?["timestamp"] as int;
      var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp);
      debugPrint("$TAG start.timestamp: ${date.format(pattern: 'mm:ss')}");
    }
    debugPrint("$TAG service.start");
    timerCount();
  });

  // 監聽 'stop' 事件，停止服務
  service.on('stop').listen((event) {
    debugPrint("$TAG service.stop");
    service.stopSelf();
    if(timer != null) timer!.cancel();
    timer = null;
  });

  // 碼錶變數

  // 初始通知（可以根據需要自訂）
  service.invoke('update', {"seconds": 0, "timestamp": timestamp});
}
