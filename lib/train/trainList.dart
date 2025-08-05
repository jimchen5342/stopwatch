import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';
import 'package:myapp/widgets/module.dart';
import 'package:myapp/train/train.dart';
import 'package:myapp/system/fetch.dart';

class TrainList extends StatefulWidget {
  const TrainList({super.key});

  @override
  State<TrainList> createState() => _TrainListState();
}

class _TrainListState extends State<TrainList> {
  StorageManager storage = StorageManager();
  List<dynamic> _list = [];
  int active = -1;
  var _isBusy = false;

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // storage.clear();
      active = storage.getInt("trainActive", defaultVaule: -1);
      _list = storage.getJsonArray("train");
      if (_list.isEmpty && active == -1) {
        download();
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
    // storage.setJsonArray("train", []);
    // setState(() {});
  }

  download() async {
    setState(() {
      _isBusy = true; // Show wait cursor
    });
    await Future.delayed(Duration(seconds: 1));

    _list = await fetch("train");
    storage.setJsonArray("train", _list);
    setState(() {
      _isBusy = false;
    });
  }

  String descrip(dynamic json) {
    String s1 = "";
    if (json is Map) {
      if (json.containsKey('items')) {
        var items = json["items"] as List;
        for (var i = 0; i < items.length; i++) {
          if (items[i].length > 0) {
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
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await download();
            },
          ),
        ],
      ),
      // backgroundColor: Colors.blue.withAlpha(1),
      body: _isBusy ? waitCursor() : listView(),
    );
  }

  Widget waitCursor() {
    return Center(child: CircularProgressIndicator());
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Train(timestamp: timestamp),
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
      selectedTileColor: SysColor.selectedItem,
      onTap: onTap,
    );
  }

  void showSnackBar() {
    // 可以用的，
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Hello, Snackbar!')));
  }
}
