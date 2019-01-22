import 'package:azlistview_example/demos/index.dart';
import 'package:azlistview_example/demos/page_scaffold.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AzListView example app'),
        ),
        body: ListPage([
          PageInfo("City Select", (ctx) => CitySelectRoute()),
          PageInfo("City Select(Custom header)",
              (ctx) => CitySelectCustomHeaderRoute()),
          PageInfo("Contacts List", (ctx) => ContactListRoute()),
          PageInfo(
              "IndexBar & SuspensionView", (ctx) => IndexSuspensionRoute()),
        ]),
      ),
    );
  }
}
