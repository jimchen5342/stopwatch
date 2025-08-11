import 'dart:async';
import 'dart:core';
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
  int _secondsElapsed = 0, _finalCountdown = -1, times = 0, active = -1;
  bool _isRunning = false, begin = false, showButton = true;
  dynamic json;
  List<dynamic> recoders = [];
  final ScrollController _scrollController = ScrollController();

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

  sendNotification() async {
    // 還沒有寫 message 值.....
    try {
      final result = await platform.invokeMethod<String>('sendNotification', {
        "title": "${json['title']}",
        "message": "還沒寫值.....", //
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
    bool isRunning = await _service.isRunning();
    if (isRunning == true) {
      _service.invoke("stop");
      speak("關閉");
      stopNotification();
    }
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
      if (_secondsElapsed > 0) {}
    });
  }

  @override
  void reassemble() async {
    super.reassemble();
    active = 3;
    scrollTo();
    setState(() {});
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
      } else {
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
        speak("時間 $str；停止");
        _isRunning = false;
        _secondsElapsed = 0; // 根據需求決定是否重置
        _finalCountdown = -1;
      });
    } else {
      _finalCountdown = 15;
      await speak("${json['title']}，倒數 $_finalCountdown 秒，啟動");
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
      child: Scaffold(
        appBar: appBar(
          json != null ? json['title'] : '',
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _exitSetup(),
          ),
        ),
        body: Container(
          // margin: const EdgeInsets.all(5.0),
          color: SysColor.gray,
          child: Container(margin: const EdgeInsets.all(5.0), child: body()),
        ),
      ),
    );
  }

  // SecondsToString(_list[index]["workout"]).toChinese()
  Widget body() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        header(),
        SizedBox(height: 10),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white38, width: 2),
              borderRadius: BorderRadius.circular(10.0),
            ),
            clipBehavior: Clip.hardEdge,
            child: plan(),
          ),
        ),
        footer(),
        _btnsRow(),
      ],
    );
  }

  Widget header() {
    var fontSize = 20.0;
    var red = Colors.red;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "訓練：${json != null ? SecondsToString(json["workout"]).toChinese() : ""}",
          style: TextStyle(fontSize: fontSize, color: red),
        ),
        Text(
          "休息：${json != null ? SecondsToString(json["rest"]).toChinese() : ""}",
          style: TextStyle(fontSize: fontSize, color: red),
        ),
        Text(
          "${json != null ? json["cycle"] : ""}組",
          style: TextStyle(fontSize: fontSize, color: red),
        ),
      ],
    );
  }

  Widget plan() {
    // 不能用 ListView，不然會 overflow 會有問題
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: List.generate(recoders.length, (index) {
          return Container(
            margin: const EdgeInsets.only(right: 5.0),
            width: double.infinity,
            color:
                active == index
                    ? SysColor.selectedItem
                    : (index % 2 == 0 ? SysColor.oddItem : SysColor.evenItem),
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  // margin: const EdgeInsets.only(right: 5.0),
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Text(
                    "${(index + 1).toString().padLeft(2, '0')}.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          active == index ? FontWeight.bold : FontWeight.normal,
                      color: active == index ? SysColor.primary : null,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 5.0),
                  child: Text(
                    recoders[index],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          active == index ? FontWeight.bold : FontWeight.normal,
                      color: active == index ? SysColor.primary : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget footer() {
    return Container(
      margin: const EdgeInsets.all(5.0),
      width: double.infinity,
      height: 100,
      // color: Colors.amber,
      child: Text(
        "test",
        style: TextStyle(
          fontSize: 40,
          color: _finalCountdown > 0 ? SysColor.red : null,
        ),
        textAlign: TextAlign.center,
      ),
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
          _isRunning ? '停止' : '啟動',
          backgroundColor: _isRunning ? SysColor.red : SysColor.primary,
          // 啟動
          onPressed: () {
            if (!_isRunning) {
              _toggleService();
            }
          },
          // 長按，停止
          onLongPress: () {
            if (_isRunning) {
              _toggleService();
            }
          },
        ),
      ],
    );
  }

  void scrollTo() {
    _scrollController.animateTo(
      active * 80.0, // 目標位置（以像素為單位）
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _exitSetup() {
    close();
    Navigator.of(context).pop();
  }
}
