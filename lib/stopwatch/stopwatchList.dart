import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:myapp/stopwatch/stopwatch.dart';
import 'package:myapp/stopwatch/stopwatchEdit.dart';
import 'package:myapp/system/fetch.dart';

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

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // storage.clear();
      active = storage.getInt("stopwatchActive", defaultVaule: -1);
      _list = storage.getJsonArray("stopwatch");
      if (_list.isEmpty && active == -1) {
        _list = await fetch("stopwatch");
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
      appBar: appBar("碼錶清單", actions: [
        ],
      ),
      // backgroundColor: Colors.blue.withAlpha(1),
      body: listView(),
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
            int timestamp = DateTime.now().microsecondsSinceEpoch;
            // var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp);
            // debugPrint("$TAG timestamp: ${date.format(pattern: 'mm:ss')}");

            active = index;
            storage.setInt("stopwatchActive", active);
            setState(() {});
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StopWatch(timestamp: timestamp),
                settings: RouteSettings(arguments: _list[index]),
              ),
            );
          },
        );
      },
    );
  }

  ListTile listTile(int index, IconData trailing, {Function()? onTap}) {
    return ListTile(
      key: Key('$index'),
      tileColor: index % 2 == 0 ? SysColor.oddItem : SysColor.evenItem,
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
      selectedTileColor: SysColor.selectedItem,
      onTap: onTap,
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
