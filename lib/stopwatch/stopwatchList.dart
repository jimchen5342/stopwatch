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
      // storage.clear();
      _stopwatchList = await storage.readJsonArray("stopwatch");
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
            "interval2Txt": "運動",
          },
          {
            "key": 3,
            "title": "健走",
            "interval": 1,
            "interval1": 1,
            "interval1Txt": "跑步",
            "interval2": 20,
            "interval2Unit": "S",
            "interval2Txt": "慢走",
          },
        ];
        storage.writeJsonArray("stopwatch", _stopwatchList);
      }
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
  }

  String descrip(dynamic json) {
    String s1 = "";

    if (json is Map) {
      if (json.containsKey('interval') && json["interval"] > 0) {
        s1 = '間隔 ${json['interval']} 分鐘報時';
      }
      if (json["interval1"] is num && json["interval1"] > 0) {
        String unit =
            json["interval1Unit"] is String && json["interval1Unit"] == "S"
                ? "秒"
                : "分";
        s1 +=
            "${s1.isNotEmpty ? '；' : ''}${json["interval1"]}${unit}鐘後${json["interval1Txt"]}";
      }
      if (json["interval2"] is num && json["interval2"] > 0) {
        String unit =
            json["interval2Unit"] is String && json["interval2Unit"] == "S"
                ? "秒"
                : "分";
        s1 += "，${json["interval2"]}${unit}鐘後${json["interval2Txt"]}";
      }
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
          // 新增
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StopWatchEdit()),
              );
              if (result != null) {
                setState(() {
                  _stopwatchList.add(result);
                });
              }
            },
          ),
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
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              softWrap: false,
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
              setState(() {
                if (result != null) {
                  for (var el in _stopwatchList) {
                    if (el["key"] == result["key"]) {
                      el = result;
                      break;
                    }
                  }
                } else {
                  _stopwatchList.removeAt(index);
                }
              });

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
