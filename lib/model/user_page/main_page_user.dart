import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:seals_kust_agro/main.dart';
import  'package:seals_kust_agro/model/setting/globalvar.dart' as global;
import 'package:seals_kust_agro/model/user_page/historyObjectListGet.dart';
import 'package:seals_kust_agro/model/user_page/servicesObjHistory.dart';
import 'package:get/get.dart';

class Task{
  String task;
  int taskvalue;
  Color colors;
  Task({required this.task, required this.taskvalue, required this.colors});
}



class UserPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home:Home()
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final UserController W = Get.find();
  late List<dynamic> data = [];
  Map<String, dynamic>? statsIndia;
  List<charts.Series<Task, String>> _seriesPieData = List<charts.Series<Task, String>>.empty(growable: true);
  late int a, b, c;

  Future<Null> getUserDetails() async {


    HttpClient client = new HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

    final String url = global.urlVar +  '/PIE' + '?data_area=' + global.dataArea;
    final request = await client
        .getUrl(Uri.parse(url))
        .timeout(Duration(seconds: 5));

    HttpClientResponse response = await request.close();

    var responseBody = await response.transform(utf8.decoder).join();


    data = json.decode(responseBody);
    statsIndia = data[0];
    a = statsIndia?["unseals"];
    b = statsIndia?["seals"];
    c = statsIndia?["free_seals"];
    print(global.nameUser);
    get();
    setState(() {});
  }


  get() {
    var piedata = [
      new Task(task: "Запломбовані об'єкти",  taskvalue: a, colors: Colors.redAccent),
      new Task(task: "Розпломбовані об'єкти", taskvalue: b, colors: Colors.greenAccent)
    ];
    _seriesPieData.add(charts.Series(
      data: piedata,
      domainFn: (Task task, _) => task.task,
      measureFn: (Task task, _) => task.taskvalue,
      colorFn: (Task task, _) => charts.ColorUtil.fromDartColor(task.colors),
      labelAccessorFn: (Task row, _) => '${row.taskvalue}',
    ));
    print(_seriesPieData.length);
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    var futureBuilder = new  FutureBuilder < List<HistrObj>>(
        future: Services.getHistrObj(),
        builder: (context, snapshot)
        {
// Data is loading, you should show progress indicator to a user
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(

            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.all(30),
            itemCount: snapshot.data?.length,
            itemBuilder: (_, index) {

              final item = snapshot.data?[index];

              return Card(

                color: ( item?.types  == "Пломбування") ? Colors.redAccent : Colors.greenAccent,
                margin: EdgeInsets.symmetric(vertical: 7),
                child: ListTile(
                  title: Text(
                      "${item?.seal_number}",
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text("${item?.seals}"),

                  leading: Icon(
                    Icons.home_outlined,
                    size: 30,
                    color: Colors.black87,
                  ),
                ),
              );

            },
          );
        }

    );
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.blue, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
          ),

          child: SingleChildScrollView(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 50,
              ),
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('image/149071.png'),
              ),
              Text(
                global.nameUser,
                style: TextStyle(
                  fontSize: 25,
                ),
              ),
              Text(
                global.dataArea,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.red[400],
                  letterSpacing: 2.5,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              FloatingActionButton.extended(
                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );

                  W.setName("");
                  global.nameUser = null;
                  global.dataArea = 'Користувач не авторизований';
                  global.urlVar  = '';
                },
                label: const Text('Вийти з профіля'),
                icon: const Icon(Icons.east_outlined),
                backgroundColor: Colors.pink,

              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  height: 250,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        _seriesPieData.length > 0
                            ? Expanded(
                          child: charts.PieChart(
                            _seriesPieData,
                            animate: true,
                            animationDuration: Duration(seconds: 1),
                            behaviors: [
                              new charts.DatumLegend(
                                outsideJustification:
                                charts.OutsideJustification.endDrawArea,
                                horizontalFirst: false,
                                desiredMaxRows: 1,
                                cellPadding: new EdgeInsets.only(
                                    right: 4.0, bottom: 4.0),
                                entryTextStyle: charts.TextStyleSpec(
                                    color: charts
                                        .MaterialPalette.purple.shadeDefault,

                                    fontSize: 15),
                              ),
                            ],
                            defaultRenderer: new charts.ArcRendererConfig(
                                arcWidth: 70,
                                arcRendererDecorators: [
                                  new charts.ArcLabelDecorator(
                                      labelPosition:
                                      charts.ArcLabelPosition.inside)
                                ]),
                          ),
                        )
                            : Container(
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),

                  )
              ),
              Container(
                height: 30,
                padding: EdgeInsets.only(left: 15, right: 15,bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(

                          "Лічильник доступних пломб:" + '$c',
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),


                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Останні події по структурному підрозділі:",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 300,
                child: futureBuilder,


              ),
            ],
          )


      ),
    ),
    );
  }

}
