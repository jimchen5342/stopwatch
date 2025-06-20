import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';

Future<String?> alert(
  BuildContext context,
  String msg, {
  String? ok,
  String? cancel,
  String? no,
  List<Widget>? actions,
}) async {
  List<Widget> _actions = [];
  if (actions != null) {
    _actions = actions;
  } else {
    if (cancel != null) {
      _actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(cancel);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(cancel),
        ),
      );
    }
    if (no != null) {
      _actions.add(
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(no);
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontSize: 18.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: Text(no),
        ),
      );
    }
  }
  if (_actions.isEmpty || ok != null) {
    _actions.add(
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(ok ?? "確定");
        },
        style: TextButton.styleFrom(
          backgroundColor: SysColor.primary,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(ok ?? "確定"),
      ),
    );
  }

  return showDialog<String>(
    context: context,
    barrierDismissible: false, // 使用者必須點按鈕關閉
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('StopWatch'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
        titlePadding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 0.0),
        // titleTextStyle: const TextStyle(
        //   fontSize: 20.0,
        //   fontWeight: FontWeight.bold,
        // ),
        contentPadding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 35.0),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Divider(),
              SizedBox(height: 10),
              Text(msg, style: TextStyle(fontSize: 20.0)),
            ],
          ),
        ),
        actions: _actions,
      );
    },
  );
}
