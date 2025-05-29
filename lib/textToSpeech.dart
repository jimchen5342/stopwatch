// ignore_for_file: camel_case_types

import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  late FlutterTts flutterTts;
  String ttsLanguage = "zh-TW"; // 預設中文台灣

  TextToSpeech() {
    flutterTts = FlutterTts();
    _getDefaultEngine();
    _getDefaultVoice();

    flutterTts.setStartHandler(() {
        print("Playing");
    });

    flutterTts.setCompletionHandler(() {
        print("Complete");
    });

    flutterTts.setCancelHandler(() {
      print("Cancel");
    });

    flutterTts.setPauseHandler(() {
      print("Paused");
    });

    flutterTts.setContinueHandler(() {
      print("Continued");
    });

    flutterTts.setErrorHandler((msg) {
        print("error: $msg");
    });
    // flutterTts.setLanguage("");
    // await flutterTts.getLanguages
  }

  setup() async {
    try {
      dynamic languages = await flutterTts.getLanguages;
      // print("languages: $languages");
      // if (languages != null) {
        await flutterTts.setLanguage(ttsLanguage);
        await flutterTts.setSpeechRate(0.5);
        await flutterTts.setVolume(1.0);
        await flutterTts.setPitch(1.0);
    } catch (e) {
        print("設定 TTS 語言失敗: $e");
        // 可以設定一個備用語言或讓 TTS 使用系統預設
    }
  }

  Future<void> speak(String text) async{
    var result = await flutterTts.speak(text);
    print('$text: $result');
    // if (result == 1) setState(() => ttsState = TtsState.playing);
  }

  Future<void> _getDefaultEngine() async {
    var engine = await flutterTts.getDefaultEngine;
    if (engine != null) {
      print(engine);
    }
  }

  Future<void> _getDefaultVoice() async {
    var voice = await flutterTts.getDefaultVoice;
    if (voice != null) {
      print(voice);
    }
  }
}