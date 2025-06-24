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
  bool _sort = false;

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
        "計時清單",
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
        ],
      ),
      body: _sort ? reorderable() : listview(),
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
          storage.setJsonArray("countdown", _list);
        });
      },
    );
  }

  Widget listview() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _list.length,
      itemBuilder: (BuildContext context, int index) {
        return listTile(
          index,
          Icons.keyboard_arrow_right,
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
          Text(_list[index]["title"], style: TextStyle(fontSize: 22)),
          // Text(
          //   "key: ${_list[index]["key"]}",
          //   style: TextStyle(fontSize: 16, color: Colors.red),
          // ),
        ],
      ),
      subtitle: Text(
        descrip(_list[index]),
        style: TextStyle(fontSize: 14),
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
