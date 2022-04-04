import 'package:flutter/material.dart';
import 'package:seals_kust_agro/model/object_main/object_sl.dart';
import 'package:seals_kust_agro/model/object_main/object_unsl.dart';

class Status_Obj extends StatefulWidget {

  Status_Obj() : super();
  @override
  _JsonParseSAddealsState createState() => _JsonParseSAddealsState();
}

class _JsonParseSAddealsState extends State <StatefulWidget> {

  @override
  Widget build(BuildContext context) {

    return new MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(
                  text: 'Запломбовані',
                ),
                Tab(
                  text: 'Розпломбовані',
                ),
              ],
            ),
            title: Text("Об'єкти"),
          ),
          body: TabBarView(
            children: [
               MainObject_SL(),
              MainObject_UN(),
          ]
          ),

        ),
      ),
    );
  }
}





class MainObject_SL extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:JsonParseObjectSts_SL()
    );
  }
}

class MainObject_UN extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body:JsonParseObjectSts_UN()
    );
  }
}
