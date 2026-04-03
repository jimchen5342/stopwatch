import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/system/textToSpeech.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:flutter/services.dart';

String TAG = "Counting";

class Counting extends StatefulWidget {
  final int timestamp;
  const Counting({super.key, this.timestamp = 0});

  @override
  State<Counting> createState() => _CountingState();
}

class _CountingState extends State<Counting> {
  TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _isRunning = false, begin = false, showButton = true;
  static const platform = MethodChannel('com.flutter/MethodChannel');

  @override
  initState() {
    super.initState();
    tts.setup();
    _checkServiceStatus();

    // 監聽來自背景服務的 'update' 事件
    _service.on('update').listen((event) {
      if (event != null && event.containsKey("timestamp")) {
        // int timestamp = event["timestamp"] as int;
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
      
    });
  }

  @override
  void dispose() async {
    close();
    super.dispose();
  }

  sendNotification() async {
    try {
      final result = await platform.invokeMethod<String>('sendNotification', {
        "title": "計次",
        "message": "", //descript().replaceAll("\n", "；"),
      });
      bool isRunning = await _service.isRunning();
      if (isRunning) {
        // 如果正在運行，則停止服務
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
    // var date = new DateTime.fromMicrosecondsSinceEpoch(widget.timestamp);
    // debugPrint("$TAG close: ${date.format(pattern: 'mm:ss')}");
    bool isRunning = await _service.isRunning();
    if (isRunning == true) {
      _service.invoke("stop");
      speak("停上計次");
      stopNotification();
    }
    _isRunning = false;
  }

  void listenToService(int second) {
    setState(() {
      var now = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      
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
      } else {
      }
      setState(() {});
    });
  }

  void resetNextTime() {

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
        // var str = SecondsToString(_secondsElapsed).toChinese();
        // speak("時間 $str；停止碼錶");
        // _isRunning = false;
        // _secondsElapsed = 0; // 根據需求決定是否重置
        // _nextTime = -1;
        // _finalCountdown = -1;
      });
    } else {
      // _finalCountdown = 15;
      // await speak("${json['title']}，倒數 $_finalCountdown 秒，啟動碼錶");
      // _isRunning = true;
      // recoders = [];
      // resetHistory = [];
      resetNextTime();
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
    // resetHistory.add(SecondsToString(_secondsElapsed).toFormat());
    // var str = SecondsToString(_secondsElapsed).toChinese();
    // speak("時間 $str；碼錶歸零");
    // _secondsElapsed = 0;
    // _nextTime = -1;
    // _finalCountdown = -1;
    // _secondsStart = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    resetNextTime();
    setState(() {});
  }

  Future<void> speak(String txt) async {
    debugPrint("$TAG speak: $txt");
    var result = await tts.speak(txt);
    var s = "${DateTime.now().format(pattern: "HH:mm:ss:ms")} => $txt";
    // debugPrint("Counting: $s");
    // if (result == "1" && _finalCountdown == -1) {
    //   recoders.insert(0, s);
    // }
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
        "計次",
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
            // color: _finalCountdown > 0 ? SysColor.red : null,
          ),
          textAlign: TextAlign.center,
        ),
        // Container(height: 20),
        Container(
          height: 60,
          // child:
          //     showButton == false || _finalCountdown > -1 ? null : _btnsRow(),
        ),
        // if (_isRunning && _nextTime > -1)
        //   Container(
        //     margin: const EdgeInsets.all(5.0),
        //     child: Text(
        //       _nextTimeText(index),
        //       style: TextStyle(fontSize: 25, color: SysColor.primary),
        //     ),
        //   ),
        // if (recoders.isNotEmpty) SizedBox(height: 10),
        // if (recoders.isNotEmpty) _recorders(),
        // if (recoders.isEmpty) _content(),
      ],
    );
  }

  OutlinedButton _btn(
    txt, {
    Function()? onPressed,
    Function()? onLongPress,
    Color backgroundColor = Colors.blue,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        side: BorderSide(width: 5, color: backgroundColor),
      ),
      child: Text(txt, style: TextStyle(fontSize: 25, color: Colors.white)),
    );
  }

  Widget _btnsRow() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _btn(
          _isRunning ? '停止碼錶' : '啟動碼錶',
          backgroundColor: _isRunning ? SysColor.red : SysColor.primary,
          // 啟動碼錶
          onPressed: () {
            if (!_isRunning) {
              _toggleService();
            }
          },
          // 長按，停止碼錶
          onLongPress: () {
            if (_isRunning) {
              _toggleService();
            }
          },
        ),
        if (_isRunning)
          // 碼錶歸零, 要長按
          _btn(
            "碼錶歸零",
            backgroundColor: SysColor.orange,
            onPressed: null,
            onLongPress: _reset,
          ),
      ],
    );
  }

  void _exitSetup() {
    close();
    Navigator.of(context).pop();
  }
}
