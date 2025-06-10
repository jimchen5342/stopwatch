import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';
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
    

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await storage.initStorage();
      // storage.clear();

      _stopwatchList = await storage.readJsonArray("stopwatch");
      // print(_stopwatchList);
      if (_stopwatchList.isEmpty) {
        _stopwatchList = [
          {"key": 1, "title": "預設", "interval": 1},
          {
            "key": 2,
            "title": "超慢跑",
            "interval": 1,
            "interval1": 4,
            "interval1Txt": "休息",
            "interval2": 1,
            "interval2Txt": "開始跑步",
          },
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

  @override
  void reassemble() async {
    super.reassemble();

    // defaultPage();
  }

  defaultPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StopWatchEdit(),
        settings: RouteSettings(arguments: _stopwatchList[0]),
      ),
    );
    // print(result);
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
        backgroundColor: Colors.blue,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => print('按下選單'),
        // ),
        title: Text(
          "報時碼錶清單",
          style: TextStyle(
            // fontSize: 40,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StopWatchEdit()),
              );
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.search, color: Colors.white),
          //   onPressed: () => print('按下搜尋'),
          // ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _stopwatchList.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            // leading: Icon(Icons.event_seat),
            title: Text(
              _stopwatchList[index]["title"],
              style: TextStyle(
                fontSize: 20,
                // color: Colors.white,
              ),
            ),
            subtitle: Text(
              descrip(_stopwatchList[index]),
              style: TextStyle(
                fontSize: 14,
                // color: Colors.white,
              ),
            ),
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
            onLongPress: () async {
              active = index;
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StopWatchEdit(),
                  settings: RouteSettings(arguments: _stopwatchList[index]),
                ),
              );
              if (result != null) {
                setState(() {
                  _stopwatchList.add(result);
                });
              }
              // print(_stopwatchList)
            },
            trailing: Icon(Icons.keyboard_arrow_right),
            selected: active == index,
          );
        },
      ),
    );
  }
}
