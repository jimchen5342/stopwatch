import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/system/textToSpeech.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:myapp/system/module.dart';

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
  // service.on("start").listen((event) {
  //   service.invoke('start');
  // });

  // 監聽 'stopService' 事件，停止服務
  service.on('stopService').listen((event) {
    service.stopSelf();
    // service.invoke('stop');
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

class _StopWatchState extends State<StopWatch> with WidgetsBindingObserver {
  TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  int _secondsElapsed = 0, frequency = 60, _nextTime = -1;
  bool _isRunning = false, begin = false, showButton = true;
  dynamic setting;
  List<String> recoders = [];
  var millSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String index = "-1";

  @override
  initState() {
    super.initState();
    tts.setup();
    initializeService();
    _checkServiceStatus();

    // 監聽來自背景服務的 'update' 事件
    _service.on('update').listen((event) {
      if (begin && event != null && event.containsKey("seconds")) {
        listenToService(event["seconds"]);
      }
    });

    _service.on('start').listen((event) {
      print("stopWatch: start");
    });
    _service.on('stop').listen((event) {
      print("stopWatch: stop");
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setting = ModalRoute.of(context)?.settings.arguments;
      setState(() {});
      // {key: 2, title: 超慢跑, interval: 1, interval1: 4, interval1Txt: 休息, interval2: 5, interval2Txt: 開始跑步}
      print(setting);

      // setting = {
      //   "key": 2,
      //   "title": "超慢跑",
      //   "interval": 1,
      //   "interval1": 2,
      //   "interval1Txt": "休息",
      //   "interval2": 1,
      //   "interval2Txt": "開始跑步",
      // };

      if (setting is Map && setting.containsKey('interval')) {
        frequency = setting["interval"] * 60;
      }
      if (setting is Map &&
          setting.containsKey('interval1') &&
          setting.containsKey('interval2')) {
        if (setting["interval1"] is num &&
            setting["interval2"] is num &&
            setting["interval1"] > 0 &&
            setting["interval2"] > 0) {
          _nextTime = setting["interval1"] * 60;
          index = "1";
        }
      }
    });
  }

  void listenToService(int second) {
    setState(() {
      if (second == 0) {
        millSec = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      }
      int sec = (DateTime.now().millisecondsSinceEpoch ~/ 1000) - millSec;
      _secondsElapsed = sec;
      // event["seconds"];

      // print("stopWatch: $sec / $_secondsElapsed; $second; ${DateTime.now()}");

      if (_secondsElapsed > 0 && _secondsElapsed % frequency == 0) {
        var s1 = "";
        if (_secondsElapsed >= _nextTime && _nextTime > -1) {
          s1 = ", ${setting['interval${index}Txt']}";
          index = index == "1" ? "2" : "1";
          _nextTime = (setting["interval$index"] * 60) + _secondsElapsed;
        }
        var str = formatTime(_secondsElapsed);
        speak("時間 $str$s1");
      }
    });
  }

  @override
  void dispose() async {
    if (_isRunning) {
      _service.invoke("stopService");
      speak("關閉碼錶");
    }
    // tts = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("didChangeAppLifecycleState: $state");
    if (AppLifecycleState.detached == state) {
      // APP 被銷毀、釋放
      if (_isRunning) {
        _service.invoke("stopService");
        speak("關閉碼錶");
      }
    } else if (AppLifecycleState.paused == state) {}
  }

  @override
  void reassemble() async {
    super.reassemble();
  }

  // 檢查服務狀態並更新 UI
  void _checkServiceStatus() async {
    bool isRunning = await _service.isRunning();
    setState(() {
      _isRunning = isRunning;
      if (isRunning) {
        _isRunning = false;
        _service.invoke("stopService");
        _secondsElapsed = 0;
        // _text = "碼錶執行中... (從背景恢復)";
        // 如果服務正在運行，可以請求一次當前時間
        // 注意：這需要你在 onStart 中處理一個 'requestCurrentTime' 之類的事件
      } else {
        // _text = "";
        _secondsElapsed = 0;
      }
      setState(() {});
    });
  }

  // 啟動或停止服務的函數
  void _toggleService() async {
    setState(() {
      showButton = false;
    });
    begin = true;
    bool isRunning = await _service.isRunning();
    if (isRunning) {
      // 如果正在運行，則停止服務
      _service.invoke("stopService");
      setState(() {
        _isRunning = false;
        _secondsElapsed = 0; // 根據需求決定是否重置
        speak("停止碼錶");
      });
    } else {
      await _service.startService();
      recoders = [];
      setState(() {
        _isRunning = true;
        speak("啟動碼錶");
        // millSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      });
    }
    Timer(Duration(seconds: 2), () {
      setState(() {
        showButton = !showButton;
      });
    });
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

  void speak(String txt) async {
    var result = await tts.speak(txt);
    var s = "${DateTime.now().format(pattern: "HH:mm:ss:ms")} => $txt";
    print("stopWatch: $s");
    if (result == "1") {
      recoders.insert(0, s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        _exitSetup();
      },
      child: scaffold(),
    );
  }

  Widget scaffold() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _exitSetup(),
        ),
        title: Text(
          "報時碼錶${setting != null ? '[' + setting['title'] + ']' : ''}",
          style: TextStyle(
            // fontSize: 40,
            color: Colors.white,
          ),
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        const Center(),
        Text(
          formatDuration(_secondsElapsed),
          style: TextStyle(fontSize: 90),
          textAlign: TextAlign.center,
        ),
        // Container(height: 20),
        Container(
          // margin: const EdgeInsets.all(15.0),
          // padding: const EdgeInsets.all(3.0),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.blueAccent),
          // ),
          height: 60,
          child:
              showButton == false
                  ? null
                  : OutlinedButton(
                    onPressed: _toggleService,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 80,
                        vertical: 0,
                      ),
                      // textStyle: const TextStyle(fontSize: 16, color: Colors.white),
                      foregroundColor: Colors.white,
                      backgroundColor: _isRunning ? Colors.red : Colors.blue,
                    ),
                    child: Text(
                      _isRunning ? '停止碼錶' : '啟動碼錶',
                      style: TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
        ),
        _widget(),
      ],
    );
  }

  Widget _widget() {
    return Expanded(
      child: ListView.builder(
        itemCount: recoders.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recoders[index]),
            // contentPadding: EdgeInsets.all(0.0),
          );
        },
      ),
    );
  }

  void _exitSetup() {
    Navigator.of(context).pop();
  }
}
