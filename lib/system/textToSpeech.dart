// ignore: file_names
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/system/module.dart';
import 'dart:async';

class TextToSpeech {
  late FlutterTts flutterTts;
  String ttsLanguage = "zh-TW"; // 預設中文台灣
  String TAG = "StopWatch-TTS";

  TextToSpeech() {
    flutterTts = FlutterTts();
    _getDefaultEngine();
    _getDefaultVoice();
    // _getLanguages();

    flutterTts.setStartHandler(() {
      debugPrint(
        "$TAG: Playing....${DateTime.now().format(pattern: 'mm:ss.ms')}",
      );
    });

    // TODO: Consider handling potential issues if a new speak call occurs before the previous one completes.
    flutterTts.setCompletionHandler(() {
      debugPrint(
        "$TAG: Complete....${DateTime.now().format(pattern: 'mm:ss.ms')}",
      );
      _completer?.complete("Completed");
    });

    flutterTts.setCancelHandler(() {
      // debugPrint("$TAG: Cancel");
    });

    flutterTts.setPauseHandler(() {
      // debugPrint("Paused");
    });

    flutterTts.setContinueHandler(() {
      // debugPrint("Continued");
    });

    flutterTts.setErrorHandler((msg) {
      debugPrint("$TAG: error: $msg");
    });
  }

  setup() async {
    try {
      await flutterTts.setLanguage(ttsLanguage);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
    } catch (e) {
      // debugPrint("設定 TTS 語言失敗: $e");
      // 可以設定一個備用語言或讓 TTS 使用系統預設
    }
  }

  Completer<String>? _completer;

  Future<String> speak(String text) async {
    _completer = Completer<String>();
    var result = await flutterTts.speak(text);
    if (result == 1) {
      return _completer!.future;
    }
    return 'Failed to speak';
  }

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      debugPrint(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      // debugPrint(voice);
    }
  }

  Future<void> _getLanguages() async {
    List<dynamic> languages = await flutterTts.getLanguages;
    languages.forEach((language) {
      // debugPrint(language);
    });
  }
}
