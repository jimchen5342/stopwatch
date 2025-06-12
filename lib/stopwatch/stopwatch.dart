import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/system/textToSpeech.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:myapp/system/module.dart';

class StopWatch extends StatefulWidget {
  const StopWatch({super.key});

  @override
  State<StopWatch> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  int _secondsElapsed = 0, frequency = 60, _nextTime = -1;
  bool _isRunning = false, begin = false, showButton = true;
  dynamic json;
  List<String> recoders = [];
  var millSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String index = "-1";

  @override
  initState() {
    super.initState();
    tts.setup();
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
      json = ModalRoute.of(context)?.settings.arguments;
      setState(() {});

      if (json is Map && json.containsKey('interval')) {
        frequency = json["interval"] * 60;
      }
      calcNextTime();
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
          s1 = ", ${json['interval${index}Txt']}";
          index = index == "1" ? "2" : "1";
          _nextTime = (json["interval$index"] * 60) + _secondsElapsed;
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

  void calcNextTime() {
    if (json is Map) {
      if (json.containsKey('interval1') && json.containsKey('interval2')) {
        if (json["interval1"] is num && json["interval2"] is num) {
          if (json["interval1"] > 0 && json["interval2"] > 0) {
            _nextTime = json["interval1"] * 60;
            index = "1";
          }
        }
      }
    }
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
        _nextTime = -1;
        speak("停止碼錶");
      });
    } else {
      await _service.startService();
      recoders = [];
      setState(() {
        _isRunning = true;
        calcNextTime();
        speak("啟動碼錶");
        // millSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      });
    }
    Timer(Duration(seconds: 1), () {
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
          // ignore: prefer_interpolation_to_compose_strings
          "報時碼錶${json != null ? ' [ ' + json['title'] + ' ]' : ''}",
          style: TextStyle(
            // fontSize: 40,
            color: Colors.white,
          ),
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
          height: 45,
          child: showButton == false ? null : _btn(),
        ),
        if (_isRunning && _nextTime > -1)
          Container(
            margin: const EdgeInsets.all(5.0),
            child: Text(
              "第 ${_nextTime ~/ 60} 分鐘，${json["interval${index}Txt"]}",
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
          ),
        if (_isRunning) _list(),
        if (!_isRunning) _content(),
      ],
    );
  }

  Widget _btn() {
    return OutlinedButton(
      onPressed: _toggleService,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 0),
        // textStyle: const TextStyle(fontSize: 16, color: Colors.white),
        foregroundColor: Colors.white,
        backgroundColor: _isRunning ? Colors.red : Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        // side: BorderSide(width: 5, color: Colors.green),
      ),
      child: Text(
        _isRunning ? '停止碼錶' : '啟動碼錶',
        style: TextStyle(fontSize: 20, color: Colors.white),
      ),
    );
  }

  Widget _content() {
    String s1 = "";

    if (json is Map) {
      if (json.containsKey('interval')) {
        s1 = '間隔 ${json['interval']} 分鐘報時';
      }
      if (json["interval1"] is num && json["interval1"] > 0) {
        s1 += "\n運動 ${json["interval1"]} 分鐘"; // ，${json["interval1Txt"]}
      }
      if (json["interval2"] is num && json["interval2"] > 0) {
        s1 += "\n休息 ${json["interval2"]} 分鐘"; // ，${json["interval2Txt"]}
      }
    }

    return Expanded(
      child: Center(
        child: Text(
          s1,
          style: TextStyle(
            fontSize: 20,
            // color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _list() {
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
