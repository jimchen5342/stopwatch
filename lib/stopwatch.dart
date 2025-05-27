import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/textToSpeech.dart';
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
      initialNotificationTitle: '背景計時器',
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
  service.on("start").listen((event) {

  });

  // 監聽 'stopService' 事件，停止服務
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // 計時器變數
  int seconds = 0;
  Timer? timer;

  // 啟動計時器
  timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    seconds++;

    // 更新前景通知內容
    if (service is AndroidServiceInstance) {
      // 如果你想在通知中顯示計時器，可以在這裡更新
      service.setForegroundNotificationInfo(
        title: "背景計時器執行中",
        content: "已過時間：$seconds 秒",
      );
    }

    // 將計時器更新發送到前景 UI
    service.invoke(
      'update',
      {
        "seconds": seconds,
      },
    );
  });

  // 初始通知（可以根據需要自訂）
  service.invoke(
    'update',
    {
      "seconds": 0,
    },
  );
}

class StopWatch extends StatefulWidget {
  const StopWatch({super.key});

  @override
  State<StopWatch> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  String _text = "點擊按鈕啟動計時器";
  int _secondsElapsed = 0;
  bool _isRunning = false;

  @override
  initState() {
    super.initState();
    tts.setup();
    initializeService();

    _checkServiceStatus();

    // 監聽來自背景服務的 'update' 事件
    _service.on('update').listen((event) {
      if (event != null && event.containsKey("seconds")) {
        setState(() {
          _secondsElapsed = event["seconds"];
          _text = "計時器執行中：$_secondsElapsed 秒";
          if(_secondsElapsed > 0 && _secondsElapsed % 10 == 0) {
            tts.speak("已過 $_secondsElapsed 秒");
          }
        });
      }
    });
  }

  // 檢查服務狀態並更新 UI
  void _checkServiceStatus() async {
    bool isRunning = await _service.isRunning();
    setState(() {
      _isRunning = isRunning;
      if (isRunning) {
        _text = "計時器執行中... (從背景恢復)";
        // 如果服務正在運行，可以請求一次當前時間
        // 注意：這需要你在 onStart 中處理一個 'requestCurrentTime' 之類的事件
      } else {
        _text = "點擊按鈕啟動計時器";
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
        _text = "計時器已停止";
        _isRunning = false;
        // _secondsElapsed = 0; // 根據需求決定是否重置
      });
    } else {
      // 如果未運行，則啟動服務
      // 注意：由於 autoStart 為 false，我們需要手動啟動
      // 這裡我們假設 onStart 會自動開始計時
      // 如果你想在服務啟動後才開始計時，你需要在 onStart 中添加一個 'startTimer' 事件
      // 並在這裡 invoke('startTimer')
      await _service.startService();
      setState(() {
        _text = "計時器已啟動";
        _isRunning = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Center(child: Text('StopWatch 頁，中文')),
          IconButton(
            icon: Icon(Icons.email),
            onPressed: () {
              tts.speak("Hello World, 你好，今天天氣晴朗");
            },
          ),
          const SizedBox(height: 60),
          Text(
              _text,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _toggleService,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(_isRunning ? '停止計時器' : '啟動計時器'),
            ),

        ],
    );
  }
}
