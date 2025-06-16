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
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            SysColor.primary, //  Theme.of(context).colorScheme.inversePrimary,
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
}
