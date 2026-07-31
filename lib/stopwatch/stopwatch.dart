import 'dart:async';
import 'dart:core';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/system/textToSpeech.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:flutter/services.dart';

class StopWatch extends StatefulWidget {
  final int timestamp;
  const StopWatch({super.key, this.timestamp = 0});

  @override
  State<StopWatch> createState() => _StopWatchState();
}

class _StopWatchState extends State<StopWatch> {
  // static const String _tag = "StopWatch";
  static const MethodChannel _platform = MethodChannel('com.flutter/MethodChannel');

  final TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  StreamSubscription? _serviceSubscription;

  int _secondsElapsed = 0, _minutesElapsed = 0,
      _frequency = 60,
      _nextTime = -1,
      _finalCountdown = -1,
      _times = 0;
  bool _isRunning = false, _begin = false, _showButton = true;
  Map<String, dynamic>? _json;
  int _secondsStart = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String _currentIndex = "-1";
  List<String> _resetHistory = [];

  @override
  void initState() {
    super.initState();
    tts.setup();
    _checkServiceStatus();

    _serviceSubscription = _service.on('update').listen((event) {
      if (event != null && event.containsKey("timestamp")) {
        if (event["timestamp"] != widget.timestamp) {
          return;
        }
      }
      if (_begin && event != null && event.containsKey("seconds")) {
        _listenToService(event["seconds"]);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          _json = args;
          final interval = _json!["interval"] as int? ?? 0;
          final unit = _json!["intervalUnit"] == "S" ? 1 : 60;
          _frequency = interval * unit;
          resetNextTime();
        });
      }
    });
  }

  @override
  void dispose() {
    _serviceSubscription?.cancel();
    _close();
    super.dispose();
  }

  Future<void> sendNotification({String? msg}) async {
    if (_json == null) return;
    try {
      final result = await _platform.invokeMethod<String>('sendNotification', {
        "title": "${_json!['title']}",
        "message": msg ?? _getDescription().replaceAll("\n", "；"),
      });

      if (!mounted) return;
      
      bool isRunning = await _service.isRunning();
      if (isRunning && _finalCountdown == -1) {
        if(result == "STOP") {
          // 如果正在運行，則停止服務
          _toggleService();
        } else if(result == "NEXT") {
          _reset();
        }
      }
    } on PlatformException catch (e) {
      debugPrint("Failed: '${e.message}'.");
    }
  }

  Future<void> _stopNotification() async {
    try {
      await _platform.invokeMethod<String>('stopNotification');
    } on PlatformException catch (e) {
      debugPrint("Failed: '${e.message}'.");
    }
  }

  void _close() async {
    bool isRunning = await _service.isRunning();
    if (isRunning) {
      _service.invoke("stop");
      speak("關閉碼錶");
      _stopNotification();
    }
    _isRunning = false;
    _secondsElapsed = 0;
    _minutesElapsed = 0;
    _nextTime = -1;
    _finalCountdown = -1;
  }

  void _listenToService(int second) {
    setState(() {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (!_isRunning) return;

      if (_finalCountdown > -1) {
        if (_finalCountdown == 1) {
          _finalCountdown = -1;
          speak("開始");
          _secondsStart = now;
          _times = 0;
        } else {
          if (_finalCountdown == 5) {
            speak("倒數 $_finalCountdown 秒");
          }
          _finalCountdown--;
        } 
        return;
      }

      _secondsElapsed = now - _secondsStart;
      if (_secondsElapsed > 0) {
        String intervalSpeakText = "";
        if (_json != null && _json!.containsKey('itv1') && _json!.containsKey('itv2')) {
          final currentItv = _json!["itv$_currentIndex"];
          if (currentItv is num) {
            final diff = _nextTime - _secondsElapsed;
            if (currentItv >= 60 && diff == 10) {
              speak("倒數 $diff 秒");
            }
          }
        }

        if (_secondsElapsed >= _nextTime && _nextTime > -1) {
          intervalSpeakText = "${_json?['itv${_currentIndex}Txt'] ?? ''}";
          intervalSpeakText = intervalSpeakText.isEmpty ? " " : "，$intervalSpeakText";
          
          if (_frequency == 0 && _currentIndex == "1") {
            intervalSpeakText += "；第 ${_times + 1} 次";
            _times++;
          }

          _currentIndex = _currentIndex == "1" ? "2" : "1";
          final unit = _json!["itv${_currentIndex}Unit"] == "S" ? 1 : 60;
          final nextVal = _json!["itv$_currentIndex"] as num? ?? 0;
          _nextTime = (nextVal.toInt() * unit) + _secondsElapsed;
        }

        if ((_frequency > 0 && _secondsElapsed % _frequency == 0) || intervalSpeakText.isNotEmpty) {
          final timeStr = SecondsToString(_secondsElapsed).toChinese();
          speak("時間 $timeStr$intervalSpeakText");
        }
      }
      // 太吵了，又無法設定通知，不出聲音；2026-07-31
      // int minutes = _secondsElapsed ~/ 60;
      // if(minutes > 0 && _minutesElapsed != minutes) {
      //   _minutesElapsed = minutes;
      //   sendNotification(msg: "時間 $minutes 分鐘");
      // }
    });
  }

  // 檢查服務狀態並更新 UI
  void _checkServiceStatus() async {
    bool isRunning = await _service.isRunning();
    setState(() {
      _isRunning = false; // 初始化時強制為 false，讓使用者手動啟動
      if (isRunning) {
        _service.invoke("stop");
      }
      _secondsElapsed = 0;
      _minutesElapsed = 0;
    });
  }

  void resetNextTime() {
    final map = _json;
    if (map != null && map.containsKey('itv1') && map.containsKey('itv2')) {
      final itv1 = map["itv1"];
      final itv2 = map["itv2"];
      if (itv1 is num && itv2 is num && itv1 > 0 && itv2 > 0) {
        final unit = map["itv1Unit"] == "S" ? 1 : 60;
        _nextTime = itv1.toInt() * unit;
        _currentIndex = "1";
      }
    }
  }

  // 啟動或停止服務的函數
  void _toggleService() async {
    if (_json == null) return;
    
    setState(() {
      _showButton = false;
    });
    _begin = true;
    bool isRunning = await _service.isRunning();
    if (isRunning) {
      // 如果正在運行，則停止服務
      _stopNotification();
      _service.invoke("stop");
      setState(() {
        final str = SecondsToString(_secondsElapsed).toChinese();
        // _resetHistory.add(SecondsToString(_secondsElapsed).toFormat());
        _addHistory();
        speak("時間 $str；停止碼錶");
        _isRunning = false;
        _secondsElapsed = 0; // 根據需求決定是否重置
        _minutesElapsed = 0;
        _nextTime = -1;
        _finalCountdown = -1;
      });
    } else {
      await _service.startService();
      _service.invoke("start", {"timestamp": widget.timestamp});
      sendNotification();
      await speak("${_json?['title']}"); // ，倒數 $_finalCountdown 秒，啟動碼錶
      _finalCountdown = 10;
      _isRunning = true;
      // resetHistory = [];
      resetNextTime();
      setState(() {});
    }
    Timer(Duration(seconds: 1), () {
      setState(() {
        _showButton = !_showButton;
      });
    });
  }

  void _addHistory() {
    final startTimeStr = DateTime.fromMillisecondsSinceEpoch(_secondsStart * 1000).format(pattern: 'HH:mm:ss');
    final elapsed = SecondsToString(_secondsElapsed).toFormat();
    _resetHistory.add("$startTimeStr,$elapsed");
  }

  void _reset() async {
    _addHistory();
    var str = SecondsToString(_secondsElapsed).toChinese();
    _finalCountdown = -1;
    _secondsElapsed = 0;
    _minutesElapsed = 0;
    _isRunning = false;
    _showButton = false;
    setState(() {});
      var sec = 15;
      await speak("時間 $str；碼錶歸零，倒數 $sec 秒，重新開始");
      _nextTime = -1;
      _isRunning = true;
      _finalCountdown = sec;
      _secondsStart = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      resetNextTime();
      sendNotification();      
      setState(() {
        Timer(Duration(seconds: 1), () {
          setState(() {
            _showButton = !_showButton;
          });
        });
      });    
  }

  Future<void> speak(String txt) async {
    await tts.speak(txt);
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
        "碼錶${_json != null ? ' [ ' + _json!['title'] + ' ]' : ''}",
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
            _showButton == false || _finalCountdown > -1 ? null : _btnsRow(),
        ),
        if (_isRunning && _nextTime > -1)
          Container(
            margin: const EdgeInsets.all(5.0),
            child: Text(
              _nextTimeText(_currentIndex),
              style: TextStyle(fontSize: 25, color: SysColor.primary),
            ),
          ),
        SizedBox(height: 10),
        _buildDescriptionContent(),
        SizedBox(height: 10),
        Expanded(
          child: _history(),
        ),
      ],
    );
  }

  Widget _history() {
    return ListView.builder(
      itemCount: _resetHistory.length,
      itemBuilder: (context, index) {
        final item = _resetHistory[index];
        final parts = item.split(",");
        final time = parts.length > 1 ? parts[0] : "";
        final elapsed = parts.length > 1 ? parts[1] : item;

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("第 ${index + 1} 次", style: TextStyle(fontSize: 18, color: Colors.grey)),
              Text(time, style: TextStyle(fontSize: 18)),
              Text(elapsed, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SysColor.primary)),
            ],
          ),
        );
      },
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

  String _getDescription() {
    if (_json == null) return "";
    String s1 = "";
    final map = _json!;

    if (map.containsKey("interval") && (map["interval"] as num) > 0) {
      String unit = map["intervalUnit"] == "S" ? "秒" : "分";
      s1 = '間隔 ${map["interval"]} $unit鐘報時';
    }

    void addItv(String key) {
      if (map[key] is num && map[key] > 0) {
        String unit = map["${key}Unit"] == "S" ? "秒" : "分";
        String txt = "${map["${key}Txt"] ?? ''}";
        txt = txt.isEmpty ? "" : "後，$txt";
        s1 += "\n${map[key]} $unit鐘$txt";
      }
    }

    addItv("itv1");
    addItv("itv2");

    return s1.startsWith("\n") ? s1.substring(1) : s1;
  }

  Widget _buildDescriptionContent() {
    return Container(
      child: Center(
        child: Text(
          _getDescription(),
          style: TextStyle(fontSize: 25, color: SysColor.primary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _nextTimeText(String index) {
    var txt = "${_json?["itv${index}Txt"] ?? ''}";
    txt = txt.isEmpty ? "" : "，$txt";
    return "在 ${SecondsToString(_nextTime).toFormat()}$txt";
  }

  void _exitSetup() {
    _close();
    Navigator.of(context).pop();
  }
}