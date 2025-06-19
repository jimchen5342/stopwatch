import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';

AppBar appBar(String title, {Widget? leading, List<Widget>? actions}) {
  return AppBar(
    backgroundColor: SysColor.primary,
    leading: leading,
    title: Text(
      title,
      style: TextStyle(
        // fontSize: 40,
        color: Colors.white,
      ),
    ),
    actions: actions,
  );
}
