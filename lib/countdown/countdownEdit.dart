import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';

class CountDownEdit extends StatefulWidget {
  const CountDownEdit({super.key});

  @override
  State<CountDownEdit> createState() => _CountDownEditState();
}

class _CountDownEditState extends State<CountDownEdit> {
  @override
  initState() {
    super.initState();
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
      appBar: AppBar(
        backgroundColor: SysColor.primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _exitSetup(),
        ),
        title: Text(
          "倒數計時",
          style: TextStyle(
            // fontSize: 40,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(),
    );
  }

  void _exitSetup() {
    Navigator.of(context).pop();
  }
}
