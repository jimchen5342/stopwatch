import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:myapp/stopwatch/stopwatch.dart';
import 'package:myapp/stopwatch/stopwatchEdit.dart';

class StopWatchList extends StatefulWidget {
  const StopWatchList({super.key});

  @override
  State<StopWatchList> createState() => _StopWatchListState();
}

class _StopWatchListState extends State<StopWatchList> {
  StorageManager storage = StorageManager();
  List<dynamic> _list = [];
  int active = -1;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // storage.clear();
      _list = storage.getJsonArray("stopwatch");
      if (_list.isEmpty) {
        _list = [
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
        storage.setJsonArray("stopwatch", _list);
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
        String unit =
            json["intervalUnit"] is String && json["intervalUnit"] == "S"
                ? "秒"
                : "分";
        s1 = '間隔 ${json['interval']} $unit鐘報時';
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
      appBar: appBar(
        "碼錶清單",
        actions: [
          // 新增
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _onAdd,
          ),
          // 測試用
          // IconButton(
          //   icon: Icon(Icons.delete, color: Colors.white),
          //   onPressed: () async {
          //     String? s = await alert(context, "alert 測試", ok: "yes", no: "no");
          //     print("sretuurn: $s");
          //   },
          // ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: _list.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                top:
                    index == 0
                        ? BorderSide(color: SysColor.second, width: 2)
                        : BorderSide.none,
                bottom: BorderSide(color: SysColor.second, width: 2),
              ),
            ),
            child: ListTile(
              // leading: Icon(Icons.event_seat),
              title: Text(
                _list[index]["title"],
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text(
                descrip(_list[index]),
                style: TextStyle(fontSize: 14),
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
                    settings: RouteSettings(arguments: _list[index]),
                  ),
                );
              },
              onLongPress: () async {
                active = index;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StopWatchEdit(),
                    settings: RouteSettings(arguments: _list[index]),
                  ),
                );
                setState(() {
                  if (result != null) {
                    for (var el in _list) {
                      if (el["key"] == result["key"]) {
                        el = result;
                        break;
                      }
                    }
                  } else {
                    _list.removeAt(index);
                  }
                });

                // print(_list)
              },
              trailing: Icon(Icons.keyboard_arrow_right),
              selected: active == index,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SysColor.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        onPressed: _onAdd,
        child: Icon(Icons.add, size: 30.0),
      ),
    );
  }

  void _onAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StopWatchEdit()),
    );
    if (result != null) {
      setState(() {
        _list.add(result);
      });
    }
  }
}
