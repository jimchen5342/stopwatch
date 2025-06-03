import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/system/textToSpeech.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// 初始化背景服務的函數
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // 設定 Android 前景服務的選項
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // 當服務啟動時執行的函數
      onStart: onStart,
      // 是否自動啟動服務
      autoStart: false, // 我們將手動啟動
      isForegroundMode: true,
      // 前景通知的設定
      // notificationChannelId: 'my_foreground',
      initialNotificationTitle: '背景碼錶',
      initialNotificationContent: '正在初始化...',
      foregroundServiceNotificationId: 888,
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
  service.on("start").listen((event) {});

  // 監聽 'stopService' 事件，停止服務
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // 碼錶變數
  int seconds = 0;
  Timer? timer;

  // 啟動碼錶
  timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    seconds++;
    // 更新前景通知內容
    if (service is AndroidServiceInstance) {
      // 如果你想在通知中顯示碼錶，可以在這裡更新
      service.setForegroundNotificationInfo(
        title: "背景碼錶執行中",
        content: "已過時間：$seconds 秒",
      );
    }

    // 將碼錶更新發送到前景 UI
    service.invoke('update', {"seconds": seconds});
  });

  // 初始通知（可以根據需要自訂）
  service.invoke('update', {"seconds": 0});
}

class StopWatch extends StatefulWidget {
  const StopWatch({super.key});

  @override
  State<StopWatch> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  int _secondsElapsed = 0;
  bool _isRunning = false;

  @override
  initState() {
    super.initState();

    // print(ModalRoute.of(context)?.settings.arguments);

    tts.setup();
    initializeService();

    _checkServiceStatus();

    // 監聽來自背景服務的 'update' 事件
    _service.on('update').listen((event) {
      if (event != null && event.containsKey("seconds")) {
        setState(() {
          _secondsElapsed = event["seconds"];
          if (_secondsElapsed > 0 && _secondsElapsed % 60 == 0) {
            var str = formatTime(_secondsElapsed);
            tts.speak("時間 $str");
          }
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var args = ModalRoute.of(context)?.settings.arguments;
      print(args);
    });
  }

  @override
  void dispose() async {
    _service.invoke("stopService");
    tts.speak("關閉碼錶");
    // tts = null;
    super.dispose();
  }

  // 檢查服務狀態並更新 UI
  void _checkServiceStatus() async {
    bool isRunning = await _service.isRunning();
    setState(() {
      _isRunning = isRunning;
      if (isRunning) {
        // _text = "碼錶執行中... (從背景恢復)";
        // 如果服務正在運行，可以請求一次當前時間
        // 注意：這需要你在 onStart 中處理一個 'requestCurrentTime' 之類的事件
      } else {
        // _text = "";
        _secondsElapsed = 0;
      }
    });
  }

  // 啟動或停止服務的函數
  void _toggleService() async {
    bool isRunning = await _service.isRunning();
    if (isRunning) {
      // 如果正在運行，則停止服務
      _service.invoke("stopService");
      setState(() {
        // _text = "";
        _isRunning = false;
        _secondsElapsed = 0; // 根據需求決定是否重置
        tts.speak("停止碼錶");
      });
    } else {
      await _service.startService();
      setState(() {
        // _text = "碼錶已啟動";
        _isRunning = true;
        tts.speak("啟動碼錶");
      });
    }
  }

  // 格式化時間，將秒數轉換為 HH:mm:ss 格式
  String formatDuration(int sec) {
    final hours = (sec ~/ 3600); // .toString().padLeft(2, '0');
    final minutes = ((sec % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (sec % 60).toString().padLeft(2, '0');
    var h = "";
    if (hours > 0) {
      h = "${hours.toString().padLeft(2, '0')}:";
    }
    return "$h$minutes:$seconds";
  }

  String formatTime(int sec) {
    var str = "";
    final hours = (sec ~/ 3600); // .toString().padLeft(2, '0');
    if (hours > 0) {
      str += "$hours 小時";
    }
    final minutes = ((sec % 3600) ~/ 60);
    if (minutes > 0) {
      str += "$minutes 分鐘";
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.blue, //  Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "報時碼錶",
          style: TextStyle(
            // fontSize: 40,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Center(),
          // const SizedBox(height: 60),
          Text(
            formatDuration(_secondsElapsed),
            style: TextStyle(fontSize: 80),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _toggleService,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: Text(_isRunning ? '停止碼錶' : '啟動碼錶'),
          ),
        ],
      ),
    );
  }
}
