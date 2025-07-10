import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:myapp/stopwatch/stopwatch.dart';
import 'package:myapp/stopwatch/stopwatchEdit.dart';
import 'package:flutter/services.dart';

class StopWatchList extends StatefulWidget {
  const StopWatchList({super.key});

  @override
  State<StopWatchList> createState() => _StopWatchListState();
}

class _StopWatchListState extends State<StopWatchList> {
  StorageManager storage = StorageManager();
  List<dynamic> _list = [];
  int active = -1;
  bool _sort = false;
  static const platform = MethodChannel('com.flutter/MethodChannel');

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

      storage.getInt("stopwatchActive");
      if (storage.getInt("stopwatchActive") != null) {
        active = storage.getInt("stopwatchActive")!;
      }
      debugPrint("active: $active");
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
    // try { // 可以用的
    //   final result = await platform.invokeMethod<String>('getBatteryLevel');
    //   debugPrint('Battery level at $result % .');
    // } on PlatformException catch (e) {
    //   debugPrint("Failed to get battery level: '${e.message}'.");
    // }
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
        String txt = "${json["interval1Txt"]}";
        txt = txt.isEmpty ? "" : "後$txt";
        s1 += "${s1.isNotEmpty ? '；' : ''}${json["interval1"]}${unit}鐘$txt";
      }
      if (json["interval2"] is num && json["interval2"] > 0) {
        String unit =
            json["interval2Unit"] is String && json["interval2Unit"] == "S"
                ? "秒"
                : "分";
        String txt = "${json["interval2Txt"]}";
        txt = txt.isEmpty ? "" : "後$txt";
        s1 += "，${json["interval2"]}$unit鐘$txt";
      }
    } else {}
    return s1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        "碼錶清單",
        actions: [
          if (_sort == false)
            IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: _onAdd,
            ),
          if (_list.length > 2)
            IconButton(
              icon: Icon(
                Icons.reorder_sharp,
                color: _sort ? Colors.red : Colors.white,
              ),
              onPressed: () async {
                setState(() {
                  _sort = !_sort;
                });
              },
            ),
          // 測試用
          // IconButton(
          //   icon: Icon(Icons.delete, color: Colors.white),
          //   onPressed: () async {
          //     String? s = await alert(context, "alert 測試", ok: "yes", no: "no");
          //     debugPrint("sretuurn: $s");
          //   },
          // ),
        ],
      ),
      // backgroundColor: Colors.blue.withAlpha(1),
      body: _sort ? reorderable() : listView(),
      floatingActionButton:
          (_sort == false)
              ? FloatingActionButton(
                backgroundColor: SysColor.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                onPressed: _onAdd,
                child: Icon(Icons.add, size: 30.0),
              )
              : null,
    );
  }

  Widget reorderable() {
    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      children: <Widget>[
        for (int index = 0; index < _list.length; index += 1)
          listTile(index, Icons.drag_handle),
      ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final dynamic item = _list.removeAt(oldIndex);
          _list.insert(newIndex, item);
          storage.setJsonArray("stopwatch", _list);
        });
      },
    );
  }

  Widget listView() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return listTile(
          index,
          Icons.keyboard_arrow_right,
          onTap: () async {
            active = index;
            storage.setInt("stopwatchActive", active);
            setState(() {});
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
            setState(() {});
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const StopWatchEdit(),
                settings: RouteSettings(arguments: _list[index]),
              ),
            );
            setState(() {
              if (result != null) {
                storage.setInt("stopwatchActive", active);
                for (var i = 0; i < _list.length; i++) {
                  var el = _list[i];
                  if (el["key"] == result["key"]) {
                    el = result;
                    break;
                  }
                }
              } else {
                storage.setInt("stopwatchActive", -1);
                _list.removeAt(index);
                index = -1;
              }
            });
          },
        );
      },
    );
  }

  ListTile listTile(
    int index,
    IconData trailing, {
    Function()? onTap,
    Function()? onLongPress,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color oddItemColor = colorScheme.primary.withValues(alpha: 0.05);
    final Color evenItemColor = colorScheme.primary.withValues(alpha: 0.15);

    return ListTile(
      key: Key('$index'),
      tileColor: index % 2 == 0 ? oddItemColor : evenItemColor,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _list[index]["title"],
            style: TextStyle(
              fontSize: 22,
              fontWeight: active == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          // Text(
          //   "key: ${_list[index]["key"]}",
          //   style: TextStyle(fontSize: 16, color: Colors.red),
          // ),
        ],
      ),
      subtitle: Text(
        descrip(_list[index]),
        style: TextStyle(
          fontSize: 16,
          fontWeight: active == index ? FontWeight.bold : FontWeight.normal,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        softWrap: false,
      ),
      trailing: Icon(
        trailing,
        color: trailing == Icons.keyboard_arrow_right ? null : Colors.red,
      ),
      selected: active == index,
      onTap: onTap,
      onLongPress: onLongPress,
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

  void showSnackBar() {
    // 可以用的，
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Hello, Snackbar!')));
  }
}
