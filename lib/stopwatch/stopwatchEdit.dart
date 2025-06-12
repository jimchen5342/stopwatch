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

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      json = ModalRoute.of(context)?.settings.arguments;
      if (json != null) {
        title = "編輯";
        ctrlTitle.text = json["title"];
        ctrlInterval.text = json["interval"].toString();
        if (json is Map && json.containsKey('interval1')) {
          ctrlInterval1.text = json["interval1"].toString();
        }
        if (json is Map && json.containsKey('interval2')) {
          ctrlInterval2.text = json["interval2"].toString();
        }
        if (json is Map && json.containsKey('interval1Txt')) {
          ctrlInterval1Txt.text = json["interval1Txt"];
        }
        if (json is Map && json.containsKey('interval2Txt')) {
          ctrlInterval2Txt.text = json["interval2Txt"];
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
    final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.blue,
      minimumSize: Size(88, 36),
      padding: EdgeInsets.symmetric(horizontal: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
    );
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
        Row(
          children: [
            SizedBox(width: 20),
            Text(
              "運動 ",
              style: TextStyle(
                fontSize: 20,
                // color: Colors.white,
              ),
            ),
            SizedBox(
              width: 50,
              child: TextField(
                controller: ctrlInterval1,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(),
                  // hintText: '',
                ),
                onChanged: (text) {
                  onChange(ctrlInterval1);
                },
              ),
            ),
            Text(
              " 分鐘，通知 ",
              style: TextStyle(
                fontSize: 20,
                // color: Colors.white,
              ),
            ),
            Expanded(
              child: TextField(
                controller: ctrlInterval1Txt,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(),
                  hintText: "開始休息",
                ),
                onChanged: (text) {
                  onChange(ctrlInterval1Txt);
                },
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        SizedBox(height: 10), // 第四列
        Row(
          children: [
            SizedBox(width: 20),
            Text(
              "休息 ",
              style: TextStyle(
                fontSize: 20,
                // color: Colors.white,
              ),
            ),
            SizedBox(
              width: 50,
              child: TextField(
                controller: ctrlInterval2,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(),
                  // hintText: '',
                ),
                onChanged: (text) {
                  onChange(ctrlInterval2);
                },
              ),
            ),
            Text(
              " 分鐘，通知 ",
              style: TextStyle(
                fontSize: 20,
                // color: Colors.white,
              ),
            ),
            Expanded(
              child: TextField(
                controller: ctrlInterval2Txt,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5.0),
                  border: OutlineInputBorder(),
                  hintText: "開始運動",
                ),
                onChanged: (text) {
                  onChange(ctrlInterval2Txt);
                },
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
        // Expanded(flex: 1, child: Container()),
        SizedBox(height: 20),
        if (isEdit == true)
          ElevatedButton(
            style: raisedButtonStyle,
            onPressed: () {
              save();
            },
            child: Text('存檔'),
          ),
      ],
    );
  }

  onChange(TextEditingController ctrl) {
    String text = ctrl.text;
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
    } else if (interval == 0) {
      msg = "請輸入報時頻率";
    } else if (interval1 == 0 && interval2 == 0) {
    } else if (interval1 == 0 && ctrlInterval1Txt.text.isNotEmpty) {
      msg = "請輸入第 1 個間隔時間";
    } else if (interval2 == 0 && ctrlInterval1Txt.text.isNotEmpty) {
      msg = "請輸入第 2 個間隔時間";
    } else if (interval1 > 0 && ctrlInterval1Txt.text.isEmpty) {
      msg = "請輸入第 1 通知";
    } else if (interval2 > 0 && ctrlInterval2Txt.text.isEmpty) {
      msg = "請輸入第2通知";
    } else {}

    if (msg.isNotEmpty) {
      _showMyDialog(msg);
    } else {
      StorageManager storage = StorageManager();
      List<dynamic> stopwatchList = await storage.readJsonArray("stopwatch");
      if (json == null) {
        json = {};
        var key = 1;
        for (var el in stopwatchList) {
          if (el["key"] > key) {
            key = el["key"] + 1;
          }
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
      }
      int index = stopwatchList.indexWhere((el) => el["key"] == json["key"]);
      stopwatchList[index] = json;
      await storage.writeJsonArray("stopwatch", stopwatchList);
      _exitSetup();
      isEdit = true;
    }
  }

  Future<void> _showMyDialog(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('StopWatch'),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(msg)]),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
