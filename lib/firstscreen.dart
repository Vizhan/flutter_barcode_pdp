import 'package:flutter/material.dart';

import 'dart:async';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'dbhelper.dart';
import 'barcode.dart';
import 'secondscreen.dart';
import 'anim.dart';

void main() => runApp(new BarCodeApp());

//void main() => runApp(new AnimApp()); // animation

class BarCodeApp extends StatelessWidget {

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
  @override
  BarCodesState createState() => new BarCodesState();
}

class BarCodesState extends State<BarCodes> {
  DbHelper _db = DbHelper();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

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
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SecondScreen()),
                );
              }),
        ],
      ),
      body: new FutureBuilder<List<String>>(
        future: fetchBarCodesFromDatabase(),
        builder: (context, snapshot) {
          if (snapshot.data == null) return new Container();
          if (snapshot.data.length == 0) {
            return new Center(
              child: Text("There is no bar codes yet"),
            );
          }

          if (snapshot.hasData) {
            return new ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return new ListTile(
                    leading: const Icon(Icons.crop_free),
                    title: new Text(snapshot.data[index]),
                  );
                });
          }
        },
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: scan,
        child: const Icon(Icons.filter_center_focus),
      ),
    );
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      _showSnackBar("Bar code saved");

      setState(() {
        var barCode = BarCode(barcode);
        _db.saveBarCode(barCode);
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        _showSnackBar('The user did not grant the camera permission!');
      } else {
        _showSnackBar('Unknown error: $e');
      }
    } on FormatException {
      _showSnackBar(
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      _showSnackBar('Unknown error: $e');
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
