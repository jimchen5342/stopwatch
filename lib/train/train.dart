import 'dart:async';
import 'dart:core';
import 'dart:nativewrappers/_internal/vm/lib/ffi_patch.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/system/textToSpeech.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:flutter/services.dart';

String TAG = "Train";

class Train extends StatefulWidget {
  final int timestamp;
  const Train({super.key, this.timestamp = 0});

  @override
  State<Train> createState() => _TrainState();
}

class _TrainState extends State<Train> {
  TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  int _secondsElapsed = 0,  frequency = 60, _nextTime = -1,
      _finalCountdown = -1, times = 0;
  bool _isRunning = false, begin = false, showButton = true;
  dynamic json;
  List<dynamic> recoders = [];
  
  var _secondsStart = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String index = "-1";
  static const platform = MethodChannel('com.flutter/MethodChannel');

  @override
  initState() {
    super.initState();
    tts.setup();
    _checkServiceStatus();

    // 監聽來自背景服務的 'update' 事件
    _service.on('update').listen((event) {
      if (event != null && event.containsKey("timestamp")) {
        int timestamp = event["timestamp"] as int;
        // var date1 = new DateTime.fromMicrosecondsSinceEpoch(widget.timestamp);
        // var date2 = new DateTime.fromMicrosecondsSinceEpoch(timestamp);
        // debugPrint(
        //   "$TAG widget.timestamp: ${date1.format(pattern: 'mm:ss')}, update.timestamp: ${date2.format(pattern: 'mm:ss')}, ${event["timestamp"] == widget.timestamp}",
        // );
        if (event["timestamp"] != widget.timestamp) {
          return;
        }
      }
      if (begin && event != null && event.containsKey("seconds")) {
        listenToService(event["seconds"]);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      json = ModalRoute.of(context)?.settings.arguments;
      setState(() {});
       
      if (json is Map) {
        if (json.containsKey("items")) {
          recoders = json["items"] as List<dynamic>;
        }
      }
    });
  }

  @override
  void dispose() async {
    close();
    super.dispose();
  }

  sendNotification() async { // 還沒有寫 message 值.....
    try {
      final result = await platform.invokeMethod<String>('sendNotification', {
        "title": "${json['title']}",
        "message": "還沒寫值.....", // 
      });
      bool isRunning = await _service.isRunning();
      if (isRunning) { // 如果正在運行，則停止服務
        _toggleService();
      }
      debugPrint('sendNotification.result: $result');
    } on PlatformException catch (e) {
      debugPrint("Failed to get battery level: '${e.message}'.");
    }
  }

  stopNotification() async {
    try {
      final result = await platform.invokeMethod<String>('stopNotification');
      debugPrint('stopNotification.result: $result');
    } on PlatformException catch (e) {
      debugPrint("Failed to get battery level: '${e.message}'.");
    }
  }

  void close() async {
    bool isRunning = await _service.isRunning();
    if (isRunning == true) {
      _service.invoke("stop");
      speak("關閉碼錶");
      stopNotification();
    }
    _isRunning = false;
    _secondsElapsed = 0;
    _nextTime = -1;
    _finalCountdown = -1;
    // _service.on('update').listen(null);
    // tts = null;
  }

  void listenToService(int second) {
    setState(() {
      var now = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      if (_finalCountdown > -1) {
        if (_finalCountdown == 20 ||
            _finalCountdown == 10 ||
            _finalCountdown == 5) {
          speak("倒數 $_finalCountdown 秒");
        } else if (_finalCountdown == 1) {
          speak("開始");
          _secondsStart = now;
          times = 0;
        }
        _finalCountdown--;
        return;
      }

      _secondsElapsed = now - _secondsStart;
      // debugPrint("$TAG _secondsElapsed: $_secondsElapsed, _nextTime: $_nextTime");
      if (_secondsElapsed > 0) {
        var s1 = "";
        if (json.containsKey('interval1') && json.containsKey('interval2')) {
          if (json["interval1"] is num && json["interval2"] is num) {
            var isec = json["interval$index"],
                idiff = _nextTime - _secondsElapsed;
            if (isec >= 60 && idiff == 10) {
              speak("倒數 $idiff 秒");
            }
          }
        }
        if (_secondsElapsed >= _nextTime && _nextTime > -1) {
          s1 = "${json['interval${index}Txt']}";
          s1 = s1.isEmpty ? " " : "，$s1";
          if (frequency == 0 && index == "1") {
            s1 += "；第 ${times + 1} 次";
            times++;
          }

          index = index == "1" ? "2" : "1";
          var sec2 =
              json["interval${index}Unit"] is String &&
                      json["interval${index}Unit"] == "S"
                  ? 1
                  : 60;
          _nextTime = (json["interval$index"] * sec2) + _secondsElapsed;
        }

        if ((frequency > 0 && _secondsElapsed % frequency == 0) ||
            s1.isNotEmpty) {
          var str = SecondsToString(_secondsElapsed).toChinese();
          speak("時間 $str$s1");
        }
      }
    });
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
        _service.invoke("stop");
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
      stopNotification();
      _service.invoke("stop");
      setState(() {
        var str = SecondsToString(_secondsElapsed).toChinese();
        speak("時間 $str；停止碼錶");
        _isRunning = false;
        _secondsElapsed = 0; // 根據需求決定是否重置
        _nextTime = -1;
        _finalCountdown = -1;
      });
    } else {
      _finalCountdown = 15;
      await speak("${json['title']}，倒數 $_finalCountdown 秒，啟動碼錶");
      _isRunning = true;
      setState(() {});
      await _service.startService();
      _service.invoke("start", {"timestamp": widget.timestamp});
      sendNotification();
    }
    Timer(Duration(seconds: 1), () {
      setState(() {
        showButton = !showButton;
      });
    });
  }

  void _reset() {
    var str = SecondsToString(_secondsElapsed).toChinese();
    speak("時間 $str；碼錶歸零");
    _secondsElapsed = 0;
    _nextTime = -1;
    _finalCountdown = -1;
    _secondsStart = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    setState(() {});
  }

  Future<void> speak(String txt) async {
    debugPrint("$TAG speak: $txt");
    var result = await tts.speak(txt);
    var s = "${DateTime.now().format(pattern: "HH:mm:ss:ms")} => $txt";
    // debugPrint("stopWatch: $s");
    return;
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
      appBar: appBar(
        "碼錶${json != null ? ' [ ' + json['title'] + ' ]' : ''}",
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _exitSetup(),
        ),
      ),
      body: Center(child: body()),
    );
  }

  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "test",
          style: TextStyle(
            fontSize: 90,
            color: _finalCountdown > 0 ? SysColor.red : null,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

   void _exitSetup() {
    close();
    Navigator.of(context).pop();
  }
}
