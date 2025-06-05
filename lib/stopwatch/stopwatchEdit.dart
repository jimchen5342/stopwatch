import 'package:flutter/material.dart';
import 'package:myapp/system/storage.dart';

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
        SizedBox(height: 10), // 第二列
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
              " 分鐘",
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
              "第 ",
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
              "第 ",
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
        Expanded(flex: 1, child: Container()),
        ElevatedButton(
          style: raisedButtonStyle,
          onPressed: () {},
          child: Text('存檔'),
        ),
      ],
    );
  }

  onChange(TextEditingController ctrl) {
    String text = ctrl.text;
    print('First text field: $text (${text.characters.length})');
  }

  void _exitSetup() {
    Navigator.of(context).pop();
    print("stopWatchEdit.pop");
  }

  save() async {
    StorageManager storage = StorageManager();
    List<dynamic> _stopwatchList = await storage.readJsonArray("stopwatch");
  }
}
