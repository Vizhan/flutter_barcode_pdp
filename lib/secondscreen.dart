import 'package:flutter/material.dart';
import 'dbhelper.dart';

class SecondScreen extends StatelessWidget {
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: new AppBar(
          title: const Text('Settings'),
        ),
        body: new Center(
          child: new RaisedButton(
            padding: const EdgeInsets.all(20.0),
            child: const Text("Clear database"),
            elevation: 6.0,
            textColor: Colors.black,
            color: Colors.amber,
            onPressed: () {
              _clearDatabase();
              _showSnackBar("Database cleared");
            },
          ),
        ));
  }

  void _clearDatabase() {
    var dbHelper = DbHelper();
    dbHelper.nukeDatabase();
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }
}
