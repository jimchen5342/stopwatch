import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/system/textToSpeech.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:flutter/services.dart';

String TAG = "StopWatch";

class StopWatch extends StatefulWidget {
  final int timestamp;
  const StopWatch({super.key, this.timestamp = 0});

  @override
  State<StopWatch> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  int _secondsElapsed = 0,
      frequency = 60,
      _nextTime = -1,
      _finalCountdown = -1,
      times = 0;
  bool _isRunning = false, begin = false, showButton = true;
  dynamic json;
  List<String> recoders = [];
  var _secondsStart = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String index = "-1";
  List<String> resetHistory = [];
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

      if (json is Map && json.containsKey("interval")) {
        var sec =
            (json["intervalUnit"] is String && json["intervalUnit"] == "S"
                ? 1
                : 60);
        frequency = json["interval"] * sec;
      }
      resetNextTime();
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
        "title": "${json['title']}",
        "message": descript().replaceAll("\n", "；"),
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
        if (json.containsKey('itv1') && json.containsKey('itv2')) {
          if (json["itv1"] is num && json["itv2"] is num) {
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

  void resetNextTime() {
    if (json is Map) {
      if (json.containsKey('itv1') && json.containsKey('itv2')) {
        if (json["itv1"] is num && json["itv2"] is num) {
          if (json["itv1"] > 0 && json["itv2"] > 0) {
            var sec =
                json["itv1Unit"] is String && json["itv1Unit"] == "S" ? 1 : 60;
            _nextTime = json["itv1"] * sec;
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
      recoders = [];
      resetHistory = [];
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
    resetHistory.add(SecondsToString(_secondsElapsed).toFormat());
    var str = SecondsToString(_secondsElapsed).toChinese();
    speak("時間 $str；碼錶歸零");
    _secondsElapsed = 0;
    _nextTime = -1;
    _finalCountdown = -1;
    _secondsStart = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    resetNextTime();
    setState(() {});
  }

  Future<void> speak(String txt) async {
    debugPrint("$TAG speak: $txt");
    var result = await tts.speak(txt);
    var s = "${DateTime.now().format(pattern: "HH:mm:ss:ms")} => $txt";
    // debugPrint("stopWatch: $s");
    if (result == "1" && _finalCountdown == -1) {
      recoders.insert(0, s);
    }
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
        _history(),
        Text(
          SecondsToString(
            _finalCountdown > 0 ? _finalCountdown : _secondsElapsed,
          ).toFormat(),
          style: TextStyle(
            fontSize: 90,
            color: _finalCountdown > 0 ? SysColor.red : null,
          ),
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
              showButton == false || _finalCountdown > -1 ? null : _btnsRow(),
        ),
        if (_isRunning && _nextTime > -1)
          Container(
            margin: const EdgeInsets.all(5.0),
            child: Text(
              _nextTimeText(index),
              style: TextStyle(fontSize: 25, color: SysColor.primary),
            ),
          ),
        if (recoders.isNotEmpty) SizedBox(height: 10),
        if (recoders.isNotEmpty) _recorders(),
        if (recoders.isEmpty) _content(),
      ],
    );
  }

  Widget _history() {
    List<Widget> arr = [];
    for (var (index, item) in resetHistory.indexed) {
      arr.add(
        Container(
          margin: EdgeInsets.only(left: index == 0 ? 0 : 10.0),
          // padding: const EdgeInsets.only(left: 3.0, right: 3.0),
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.blueAccent),
          // ),
          child: Text(
            item,
            style: TextStyle(
              fontSize: 25,
              color: index % 2 == 0 ? SysColor.primary : null,
            ),
          ),
        ),
      );
    }
    return Container(
      // margin: const EdgeInsets.all(15.0),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      // decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent)),
      height: 45,
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: arr),
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
        if (_isRunning && _secondsElapsed > 20)
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

  String descript() {
    String s1 = "";

    if (json is Map) {
      if (json.containsKey("interval") && json["interval"] > 0) {
        String unit =
            json["intervalUnit"] is String && json["intervalUnit"] == "S"
                ? "秒"
                : "分";
        s1 = '間隔 ${json["interval"]} $unit鐘報時';
      }
      if (json["itv1"] is num && json["itv1"] > 0) {
        String unit =
            json["itv1Unit"] is String && json["itv1Unit"] == "S" ? "秒" : "分";
        String txt = "${json["itv1Txt"]}";
        txt = txt.isEmpty ? "" : "後，$txt";

        s1 += "\n${json["itv1"]} $unit鐘$txt";
      }
      if (json["itv2"] is num && json["itv2"] > 0) {
        String unit =
            json["itv2Unit"] is String && json["itv2Unit"] == "S" ? "秒" : "分";
        String txt = "${json["itv2Txt"]}";
        txt = txt.isEmpty ? "" : "後，$txt";

        s1 += "\n${json["itv2"]} $unit鐘$txt";
      }
    }
    if (s1.indexOf("\n") == 0) {
      s1 = s1.substring(1);
    }
    return s1;
  }

  Widget _content() {
    return Expanded(
      child: Center(
        child: Text(
          descript(),
          style: TextStyle(fontSize: 25, color: SysColor.primary),
        ),
      ),
    );
  }

  Widget _recorders() {
    return Expanded(
      child: ListView.builder(
        itemCount: recoders.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.only(left: 10, right: 10),
            isThreeLine: false,
            minTileHeight: 10,
            title: Text(
              recoders[index],
              style: TextStyle(
                // fontSize: 25,
                color: recoders[index].contains("重新") ? SysColor.red : null,
              ),
            ),
            // contentPadding: EdgeInsets.all(0.0),
          );
        },
      ),
    );
  }

  String _nextTimeText(String index) {
    var txt = "${json["interval${index}Txt"]}";
    txt = txt.isEmpty ? "" : "，$txt";
    return "在 ${SecondsToString(_nextTime).toFormat()}$txt";
  }

  void _exitSetup() {
    close();
    Navigator.of(context).pop();
  }
}
