import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:myapp/countdown/countdown.dart';
import 'package:myapp/countdown/countdownEdit.dart';

class CountDownList extends StatefulWidget {
  const CountDownList({super.key});

  @override
  State<CountDownList> createState() => _CountDownListState();
}

class _CountDownListState extends State<CountDownList> {
  StorageManager storage = StorageManager();
  List<dynamic> _list = [];
  int active = -1;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // storage.clear();
      _list = storage.getJsonArray("countdown");
      if (_list.isEmpty) {
        _list = [
          {"key": 1, "title": "預設 1", "minutes": 5},
          {"key": 2, "title": "預設 2", "minutes": 10},
          {"key": 3, "title": "預設 3", "minutes": 30},
        ];
        storage.setJsonArray("countdown", _list);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        "倒數計時清單",
        actions: [
          // 新增
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: _onAdd,
          ),
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
                    builder: (context) => const CountDown(),
                    settings: RouteSettings(arguments: _list[index]),
                  ),
                );
              },
              onLongPress: () async {
                active = index;
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CountDownEdit(),
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

  String descrip(dynamic json) {
    String s1 = '${json['minutes']} 分鐘';
    return s1;
  }

  void _onAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CountDownEdit()),
    );
    if (result != null) {
      setState(() {
        _list.add(result);
      });
    }
  }
}
