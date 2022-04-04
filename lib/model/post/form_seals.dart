import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:seals_kust_agro/model/object_main/status_object.dart';
import 'package:seals_kust_agro/model/setting/camera_app.dart';
import 'package:seals_kust_agro/model/setting/globalvar.dart' as global;

void main() => runApp(Form_seals());

class Form_seals extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Форма пломбування')),
      body: SealsPage(),
    );
  }
}

class SealsPage extends StatefulWidget {
  @override
  _SealsPageState createState() => _SealsPageState();
}

class _SealsPageState extends State<SealsPage> {
  late List<CameraDescription> cameras;
  late CameraDescription camera;
  List? SealsList;
  String? _scanBarcode;
  String? _mySeals;
  String url = global.urlVar;
  String? _imageB64;
  String img1 = 'Фото';
  bool _isButtonDisabledImage = false;
  bool isFetching = false;
  bool _isButtonDisabledSeals = false;
  @override
  void initState() {
    _getSealsList();
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      camera = cameras.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(bottom: 20, top: 20),
              child: Text(
                'Форма пломбування',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              height: 50,
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(global.nameObj,
                        style: TextStyle(color: Colors.black, fontSize: 15)),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              padding: EdgeInsets.only(left: 15, right: 15),
              child: Row(

                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: DropdownButtonHideUnderline(

                      child: ButtonTheme(

                        alignedDropdown: true,
                        child: DropdownButton<String>(
                          value: _mySeals,
                          iconSize: 30,
                          icon: (null),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          hint: Text("Пломби"),
                          onChanged: (String? newValue) {
                            setState(() {
                              _mySeals = newValue;
                              _isButtonDisabledSeals = true;
                              print(_mySeals);
                            });
                          },
                          items: SealsList?.map((item) {
                            return new DropdownMenuItem(
                              child: new Text(item['seal_number']),
                              value: item['seal_number'].toString(),
                            );
                          })?.toList() ??
                              [],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ButtonTheme(
                        alignedDropdown: true,
                        child: new RaisedButton.icon(
                          icon: Icon(Icons.qr_code),
                          onPressed: () {
                            setState(() {
                              _scanQR();
                            });
                          },
                          label: new Text(''),
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              padding: EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text("$img1",
                        style: TextStyle(color: Colors.black, fontSize: 15)),
                  ),
                  Expanded(
                    child: ButtonTheme(
                        alignedDropdown: true,
                        child: new RaisedButton.icon(
                          label: Text('Добавити фото'), //Добавити фото
                          onPressed: () async {
                            _imageB64 = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CameraApp(id: DateTime.now().toString())),
                            );
                            if (_imageB64 != null) {
                              setState(() {
                                img1 = 'image.img';
                                _isButtonDisabledImage = true;
                              });
                            }
                          },

                          icon: Icon(Icons.camera_alt),
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: EdgeInsets.all(10.0),
              child: ButtonTheme(
                minWidth: 10.0,
                height: 40.0,
                child: RaisedButton.icon(
                  label: Text(
                    "Створити пломбування",
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                  icon: Icon(Icons.send_to_mobile),
                  onPressed: isFetching == false &&
                      _isButtonDisabledImage == true  &&
                      _isButtonDisabledSeals == true ? makeRequest : null,
                  color: Colors.blue,
                  padding: EdgeInsets.all(20.0),
                ),
              ),
              margin: EdgeInsets.only(top: 0.0),
            ),
          ],
        ),
      ),
    );
  }



  //=============================================================================== Api Calling here

  Future<void> _getSealsList() async {
    HttpClient client = new HttpClient();
    client.badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);

    final request = await client.getUrl(Uri.parse(global.urlVar +
        '/seals_list' +
        '?status=' +
        global.typesOp +
        '&data_area=' +
        global.dataArea));

    HttpClientResponse response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();

    var dataList = json.decode(responseBody);
    setState(() {
      SealsList = dataList;
    });
  }

  //Post seals_main/unseals

  Future<void> makeRequest() async {
    if(!isFetching){
      setState(() {
        isFetching = true;
      });

    HttpClient client = new HttpClient();
    client.badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);

    String url = global.urlVar + "/seals_object";

    Map map = {
      "seals": _mySeals,
      "data_area": global.dataArea,
      "object": global.nameObj,
      "type": global.typesOp,
      "user": global.nameUser,
      "image": _imageB64,
    };

    HttpClientRequest request = await client.postUrl(Uri.parse(url));

    request.headers.set('content-type', 'application/json');

    request.add(utf8.encode(json.encode(map)));

    HttpClientResponse response = await request.close();

      if (200 == response.statusCode) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Status_Obj()));
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Error_Auth()),
        );
      }
      setState((){
        isFetching=false;
      });
    }
  }


  Future _scanQR() async {
    try {
      String? cameraScanResult = await scanner.scan();
      setState(() {
        _mySeals =
            cameraScanResult;
        _isButtonDisabledSeals = true;
      });
    } on PlatformException catch (e) {
      print(e);
    }
  }
}

class Error_Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AlertDialog dialog = AlertDialog(
      title: Text('Помилка при розпломбуванні'),
      content: Text('Повторити спробу розпломбування'),
      actions: [
        FlatButton(
          textColor: Color(0xFF6200EE),
          onPressed: () => SystemNavigator.pop(),
          child: Text('Ні'),
        ),
        FlatButton(
          textColor: Color(0xFF6200EE),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Form_seals()),
            );
          },
          child: Text('Так'),
        ),
      ],
    );
    return Scaffold(body: dialog);
  }
}
