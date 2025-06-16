import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';

class CountDownList extends StatefulWidget {
  const CountDownList({super.key});

  @override
  State<CountDownList> createState() => _CountDownListState();
}

class _CountDownListState extends State<CountDownList> {
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
        backgroundColor: SysColor.primary,
        title: Text(
          "倒數計時清單",
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
