import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
// import 'package:myapp/train/train.dart';
// import 'package:myapp/train/trainEdit.dart';

class TrainList extends StatefulWidget {
  const TrainList({super.key});

  @override
  State<TrainList> createState() => _TrainListState();
}

class _TrainListState extends State<TrainList> {
  StorageManager storage = StorageManager();
  List<dynamic> _list = [];
  int active = -1;
  bool _sort = false;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // storage.clear();
      _list = storage.getJsonArray("train");
      if (_list.isEmpty) {
        defalutList();
      }

      storage.getInt("trainActive");
      if (storage.getInt("trainActive") != null) {
        active = storage.getInt("trainActive")!;
      }
      // debugPrint("active: $active");
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
    // storage.setJsonArray("train", []);
    // defalutList();
    // setState(() {});
  }

  void defalutList() {
    _list = [
      {"key": 1000, "title": "啞鈴", "workout": 60, "rest": 30, "cycle": 2,
        "items": ["肩推", "彎舉", "前平舉", "側平舉"]},
      {"key": 1001, "title": "平板撐", "workout": 60 * 2, "rest": 60, "cycle": 2,
         "items": ["俯身登山跑", "俯身側跨步", "俯身收腿跳", "肘支撐開合跳"]},
      {"key": 1002, "title": "高強度間歇訓練", "workout": 60 * 2, "rest": 30, "cycle": 2,
        "items": ["開合跳", "跨下擊掌", "單側提膝", "對側提膝", "提膝下壓", "向後踢腿", "原地踢臀", "深蹲"]},
      {"key": 1003, "title": "彈力帶", "workout": 30, "rest": 1, "cycle": 2,
        "items": ["二頭彎舉", "過頭肩推", "前平舉", "肩背下拉", "", "", "", ""]},
    ];
    storage.setJsonArray("train", _list);
  }

  String descrip(dynamic json) {
    String s1 = "";
    if (json is Map) {
      if (json.containsKey('items')){
        var items = json["items"] as List;
        for(var i = 0; i < items.length;i++){
          if(items[i].length > 0) {
            s1 += (s1.isNotEmpty ? ", " : "") + items[i];
          }
        }
      }
    }
    return s1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        "訓練清單",
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
          //   icon: Icon(Icons.delete, color: Colors.red),
          //   onPressed: () async {

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
          storage.setJsonArray("train", _list);
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
            int timestamp = DateTime.now().microsecondsSinceEpoch;

            active = index;
            storage.setInt("trainActive", active);
            setState(() {});
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => Train(timestamp: timestamp),
            //     settings: RouteSettings(arguments: _list[index]),
            //   ),
            // );
          },
          onLongPress: () async {
            active = index;
            setState(() {});
            // final result = await Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => const TrainEdit(),
            //     settings: RouteSettings(arguments: _list[index]),
            //   ),
            // );
            setState(() {
              // if (result != null) {
              //   storage.setInt("trainActive", active);
              //   for (var i = 0; i < _list.length; i++) {
              //     var el = _list[i];
              //     if (el["key"] == result["key"]) {
              //       el = result;
              //       break;
              //     }
              //   }
              // } else {
              //   storage.setInt("trainActive", -1);
              //   _list.removeAt(index);
              //   index = -1;
              // }
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _list[index]["title"],
            style: TextStyle(
              fontSize: 22,
              fontWeight: active == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            SecondsToString(_list[index]["workout"]).toChinese(),
            style: TextStyle(fontSize: 20, color: Colors.red),
          ),
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
    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const TrainEdit()),
    // );
    // if (result != null) {
    //   setState(() {
    //     _list.add(result);
    //   });
    // }
  }

  void showSnackBar() { // 可以用的，
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Hello, Snackbar!')));
  }
}
