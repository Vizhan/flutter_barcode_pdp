import 'package:flutter/material.dart';

import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dbhelper.dart';
import 'barcode.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      theme: new ThemeData(
        primaryColor: Colors.amber,
      ),
      home: new BarCodes(),
    );
  }
}

class BarCodes extends StatefulWidget {
  BarCodes({Key key}) : super(key: key);

  @override
  BarCodesState createState() => new BarCodesState();
}

class BarCodesState extends State<BarCodes> {
  DbHelper _db = DbHelper();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

  final List<String> _saved = <String>[];

  String barcode = "";

  @override
  void initState() {
    super.initState();
    _db.initDb();
  }

  @override
  void dispose() {
    _db.closeDb();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: scaffoldKey,
      appBar: new AppBar(
        title: new Text('Barcode Scanner'),
        actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.settings), onPressed: _pushSaved),
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new FutureBuilder<List<String>>(
            future: fetchBarCodesFromDatabase(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return new ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return new ListTile(
                        leading: const Icon(Icons.crop_free),
                        title: new Text(snapshot.data[index]),
                        trailing: new Icon(Icons.close),
                      );
                    });
              }
              return new Text("No Data found");
//              return new Container(
//                alignment: AlignmentDirectional.center,
//                child: new CircularProgressIndicator(),
//              );
            },
          ),
//          _buildBarCodesList(),
          new Container(
            alignment: const Alignment(1.0, 1.0),
            padding: const EdgeInsets.all(32.0),
            child: new FloatingActionButton(
              onPressed: scan,
              child: const Icon(Icons.filter_center_focus),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarCodesList() {
    final Iterable<ListTile> tiles = _saved.map(
          (String pair) {
        return new ListTile(
          leading: const Icon(Icons.crop_free),
          title: new Text(pair),
          trailing: new Icon(Icons.close),
        );
      },
    );

    final List<Widget> divided = ListTile
        .divideTiles(
      context: context,
      tiles: tiles,
    )
        .toList();

    return ListView(padding: const EdgeInsets.all(16.0), children: divided);
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final scaffold = new GlobalKey<ScaffoldState>();
          return new Scaffold(
              key: scaffoldKey,
              // Add 6 lines from here...
              appBar: new AppBar(
                title: const Text('Settings'),
              ),
              body: new Center(
                child: new RaisedButton(
                  padding: const EdgeInsets.all(20.0),
                  child: const Text("Nuke database"),
                  elevation: 6.0,
                  textColor: Colors.black,
                  color: Colors.amber,
                  onPressed: () {
                    _nukeData;
                  }
                ),
              ));
        },
      ),
    );
  }

  void _nukeData() {
    var dbHelper = DbHelper();
    dbHelper.nukeDatabase();

    _showSnackBar("Cleared");
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();

      setState(() {
//        _saved.add(barcode);

        var barCode = BarCode(barcode);
        _db.saveBarCode(barCode);

        _showSnackBar("Data saved successfully");

        this.barcode = barcode;
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          _saved.add(barcode);
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        _saved.add(barcode);
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException {
      _saved.add(barcode);
      setState(() =>
      this.barcode =
      'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      _saved.add(barcode);
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void _showSnackBar(String text) {
    scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(text)));
  }
}

Future<List<String>> fetchBarCodesFromDatabase() async {
  var dbHelper = DbHelper();
  Future<List<String>> barcodeList = dbHelper.getBarCodes();
  return barcodeList;
}