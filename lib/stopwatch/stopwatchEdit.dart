import 'package:flutter/material.dart';
import 'package:myapp/system/module.dart';

class StopWatchEdit extends StatefulWidget {
  const StopWatchEdit({super.key});

  @override
  State<StopWatchEdit> createState() => _StopWatchEditState();
}

class _StopWatchEditState extends State<StopWatchEdit> {
  dynamic json;
  String title = "新增";
  final ctrlTitle = TextEditingController(),
      ctrlInterval = TextEditingController(),
      ctrlInterval1 = TextEditingController(),
      ctrlInterval2 = TextEditingController(),
      ctrlInterval1Txt = TextEditingController(),
      ctrlInterval2Txt = TextEditingController();
  bool isEdit = false;
  dynamic unit = {"interval1": "M", "interval2": "M"};

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      json = ModalRoute.of(context)?.settings.arguments;
      if (json != null) {
        setState(() {});
        title = "編輯";
        ctrlTitle.text = json["title"];
        ctrlInterval.text = json["interval"].toString();
        if (json is Map) {
          if (json.containsKey('interval1')) {
            ctrlInterval1.text = json["interval1"].toString();
          }
          if (json.containsKey('interval2')) {
            ctrlInterval2.text = json["interval2"].toString();
          }
          if (json.containsKey('interval1Txt')) {
            ctrlInterval1Txt.text = json["interval1Txt"];
          }
          if (json.containsKey('interval2Txt')) {
            ctrlInterval2Txt.text = json["interval2Txt"];
          }
          if (json.containsKey('interval1Unit') &&
              json["interval1Unit"] is String) {
            unit["interval1"] = json["interval1Unit"];
          }
          if (json.containsKey('interval2Unit') &&
              json["interval2Unit"] is String) {
            unit["interval2"] = json["interval2Unit"];
          }
        }
      }
    });
  }

  @override
  void dispose() async {
    ctrlTitle.dispose();
    ctrlInterval.dispose();
    ctrlInterval1.dispose();
    ctrlInterval2.dispose();
    ctrlInterval1Txt.dispose();
    ctrlInterval2Txt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        _exitSetup();
      },
      child: scaffold(),
    );
  }

  Widget scaffold() {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _exitSetup,
        ),
        backgroundColor:
            Colors.blue, //  Theme.of(context).colorScheme.inversePrimary,
        title: Text(
          "報時碼錶[$title]",
          style: TextStyle(
            // fontSize: 40,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              json = null;
              _exitSetup();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
            minHeight: MediaQuery.of(context).size.height - 100,
          ),
          child: IntrinsicHeight(child: body()),
        ),
      ),
      //body(),
    );
  }

  Widget body() {
    return Column(
      children: [
        SizedBox(height: 10), // 第一列，標題
        Row(
          children: [
            SizedBox(width: 20),
            Text(
              "標題 ",
              style: TextStyle(
                fontSize: 20,
                // color: Colors.white,
              ),
            ),
            Expanded(
              child: TextField(
                controller: ctrlTitle,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(),
                  // labelText: "whatever you want",
                  // hintText: "whatever you want",
                  // icon: Icon(Icons.phone_iphone),
                ),
                onChanged: (text) {
                  onChange(ctrlTitle);
                },
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        SizedBox(height: 10), // 第二列，報時頻率
        Row(
          children: [
            SizedBox(width: 20),
            Text("每隔 ", style: TextStyle(fontSize: 20)),
            SizedBox(
              width: 50,
              child: TextField(
                controller: ctrlInterval,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(),
                  // labelText: "whatever you want",
                  // icon: Icon(Icons.phone_iphone),
                ),
                onChanged: (text) {
                  onChange(ctrlInterval);
                },
              ),
            ),
            Text(
              " 分鐘報時",
              style: TextStyle(
                fontSize: 20,
                // color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        SizedBox(height: 10), // 第三列
        _row("1"),
        SizedBox(height: 10), // 第四列
        _row("2"),
        // Expanded(flex: 1, child: Container()),
        SizedBox(height: 10),
        if (isEdit == true)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue,
              minimumSize: Size(120, 40),
              padding: EdgeInsets.symmetric(horizontal: 16),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(2)),
              ),
            ),
            onPressed: () {
              save();
            },
            child: Text(
              '存檔',
              style: TextStyle(
                fontSize: 20,
                // color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(String index) {
    return Row(
      children: [
        SizedBox(width: 20),
        SizedBox(
          width: 50,
          child: TextField(
            controller: index == "1" ? ctrlInterval1 : ctrlInterval2,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(5.0),
              border: OutlineInputBorder(),
              // hintText: '',
            ),
            onChanged: (text) {
              onChange(index == "1" ? ctrlInterval1 : ctrlInterval2);
            },
          ),
        ),
        SizedBox(width: 5),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            minimumSize: Size(30, 40),
            padding: EdgeInsets.symmetric(horizontal: 15),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          onPressed: () {
            setState(() {
              unit["interval$index"] =
                  unit["interval$index"] == "S" ? "M" : "S";
              isEdit = true;
            });
          },
          child: Text(
            "${unit["interval$index"] == "S" ? "秒" : "分"}鐘",
            style: TextStyle(fontSize: 18),
          ),
        ),
        SizedBox(width: 5),
        Text(
          "後，通知 ",
          style: TextStyle(
            fontSize: 20,
            // color: Colors.white,
          ),
        ),
        Expanded(
          child: TextField(
            controller: index == "1" ? ctrlInterval1Txt : ctrlInterval2Txt,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(5.0),
              border: OutlineInputBorder(),
              hintText: index == "1" ? "休息" : "運動",
            ),
            onChanged: (text) {
              onChange(index == "1" ? ctrlInterval1Txt : ctrlInterval2Txt);
            },
          ),
        ),
        SizedBox(width: 20),
      ],
    );
  }

  onChange(TextEditingController ctrl) {
    // String text = ctrl.text;
    isEdit = true;
  }

  void _exitSetup() {
    Navigator.of(context).pop(json);
  }

  save() async {
    var msg = "";
    int interval =
        int.tryParse(ctrlInterval.text) == null
            ? 0
            : int.parse(ctrlInterval.text);

    int interval1 =
        int.tryParse(ctrlInterval1.text) == null
            ? 0
            : int.parse(ctrlInterval1.text);
    int interval2 =
        int.tryParse(ctrlInterval2.text) == null
            ? 0
            : int.parse(ctrlInterval2.text);
    if (ctrlTitle.text.isEmpty) {
      msg = "請輸入標題";
    } else if (interval1 == 0 && interval2 == 0) {
      if (interval == 0) {
        msg = "請輸入報時頻率";
      }
    } else if (interval1 == 0 && ctrlInterval1Txt.text.isNotEmpty) {
      msg = "請輸入第 1 個間隔時間";
    } else if (interval2 == 0 && ctrlInterval1Txt.text.isNotEmpty) {
      msg = "請輸入第 2 個間隔時間";
    } else if (interval1 > 0 && ctrlInterval1Txt.text.isEmpty) {
      msg = "請輸入第 1 通知";
    } else if (interval2 > 0 && ctrlInterval2Txt.text.isEmpty) {
      msg = "請輸入第 2 通知";
    } else {}

    if (msg.isNotEmpty) {
      alert(context, msg);
    } else {
      StorageManager storage = StorageManager();
      List<dynamic> stopwatchList = await storage.readJsonArray("stopwatch");
      if (json == null) {
        json = {};
        var key = 1;
        for (var el in stopwatchList) {
          print('${el["key"]} / ${key}; ${el["key"] == key}');
          if (el["key"] >= key) {
            key = el["key"] + 1;
          }
          print("key: $key");
        }
        json["key"] = key;
        stopwatchList.add(json);
      }
      json["title"] = ctrlTitle.text;
      json["interval"] = interval;
      if (!(interval1 == 0 && interval2 == 0)) {
        json["interval1"] = interval1;
        json["interval2"] = interval2;
        json["interval1Txt"] = ctrlInterval1Txt.text;
        json["interval2Txt"] = ctrlInterval2Txt.text;
        if (json["interval1Unit"] == "S" ||
            (json["interval1Unit"] != unit["interval1"])) {
          json["interval1Unit"] = unit["interval1"];
        }
        if (json["interval2Unit"] == "S" ||
            (json["interval2Unit"] != unit["interval2"])) {
          json["interval2Unit"] = unit["interval2"];
        }
      }
      // print(json);
      int index = stopwatchList.indexWhere((el) {
        print("${el['key']} / ${json['key']}; ${el['key'] == json['key']}");
        return el["key"] == json["key"];
      });
      stopwatchList[index] = json;
      await storage.writeJsonArray("stopwatch", stopwatchList);
      _exitSetup();
      isEdit = true;
    }
  }
}
