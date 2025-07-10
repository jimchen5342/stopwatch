import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:myapp/system/textToSpeech.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';

class CountDown extends StatefulWidget {
  const CountDown({super.key});

  @override
  State<CountDown> createState() => _CountDownState();
}

class _CountDownState extends State<CountDown> {
  TextToSpeech tts = TextToSpeech();
  final FlutterBackgroundService _service = FlutterBackgroundService();
  dynamic json;
  bool _isRunning = false, begin = false, showButton = true;

  @override
  initState() {
    super.initState();
    tts.setup();
    // _checkServiceStatus();

    // 監聽來自背景服務的 'update' 事件
    _service.on('update').listen((event) {
      if (begin && event != null && event.containsKey("seconds")) {
        // listenToService(event["seconds"]);
      }
    });

    _service.on('start').listen((event) {
      debugPrint("stopWatch: start");
    });
    _service.on('stop').listen((event) {
      debugPrint("stopWatch: stop");
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      json = ModalRoute.of(context)?.settings.arguments;
      setState(() {});
    });
  }

  @override
  void dispose() async {
    super.dispose();
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
        // ignore: prefer_interpolation_to_compose_strings
        "計時${json != null ? ' [ ' + json['title'] + ' ]' : ''}",
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _exitSetup(),
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    return Container();
  }

  void _exitSetup() {
    Navigator.of(context).pop();
  }
}
