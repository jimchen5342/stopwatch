import 'dart:ui';
import 'package:flutter/material.dart';

class StopWatchEdit extends StatefulWidget {
  const StopWatchEdit({super.key});

  @override
  State<StopWatchEdit> createState() => _StopWatchEditState();
}

class _StopWatchEditState extends State<StopWatchEdit> {
  @override
  initState() {
    super.initState();
    // print(ModalRoute.of(context)?.settings.arguments);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      var args = ModalRoute.of(context)?.settings.arguments;
      print(args);
    });
  }

  @override
  void dispose() async {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.blue, //  Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "報時碼錶",
          style: TextStyle(
            // fontSize: 40,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(),
    );
  }
}
