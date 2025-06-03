import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myapp/system/storage.dart';
import 'package:myapp/stopwatch/stopwatch.dart';
import 'package:myapp/stopwatch/stopwatchEdit.dart';

class StopWatchList extends StatefulWidget {
  const StopWatchList({super.key});

  @override
  State<StopWatchList> createState() => _StopWatchListState();
}

class _StopWatchListState extends State<StopWatchList> {
  StorageManager storage = StorageManager();
  List<dynamic> _stopwatchList = [];
  int active = -1;

  @override
  initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await storage.initStorage();
      _stopwatchList = await storage.readJsonArray("stopwatch");
      // print(_stopwatchList);
      if (_stopwatchList.isEmpty) {
        _stopwatchList = [
          {"title": "預設", "interval": 1},
        ];
        storage.writeJsonArray("stopwatch", _stopwatchList);
      }
      // print(_stopwatchList);

      setState(() {});
    });
  }

  @override
  void dispose() async {
    super.dispose();
  }

  String descrip(dynamic json) {
    String s1 = "";

    if (json is Map && json.containsKey('interval')) {
      s1 = '間隔 ${json['interval']} 分鐘報時';
    } else {
      print('myData 不包含 key "age" 或 myData 不是一個 Map');
    }

    return s1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.blue, //  Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "報時碼錶清單",
          style: TextStyle(
            // fontSize: 40,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _stopwatchList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            // leading: Icon(Icons.event_seat),
            title: Text(_stopwatchList[index]["title"]),
            subtitle: Text(descrip(_stopwatchList[index])),
            onTap: () async {
              active = index;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StopWatch(),
                  settings: RouteSettings(arguments: _stopwatchList[index]),
                ),
              );
            },
            onLongPress: () {
              active = index;
              print("onLongPress: $index");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StopWatchEdit(),
                  settings: RouteSettings(arguments: _stopwatchList[index]),
                ),
              );
            },
            trailing: Icon(Icons.keyboard_arrow_right),
            selected: active == index,
          );
        },
      ),
    );
  }
}
