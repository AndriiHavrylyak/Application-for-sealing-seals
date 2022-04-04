import 'package:flutter/material.dart';
import 'package:seals_kust_agro/model/seals_main/seals_not_use.dart';
import 'package:seals_kust_agro/model/seals_main/seals_use.dart';
void main() => runApp(Status_Seals());

class Status_Seals extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new Seals_all());
  }
}
class Seals_all extends StatelessWidget {
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
                  text: 'Доступні',
                ),
                Tab(
                  text: 'Використані',
                ),
              ],
            ),
            title: Text('Пломби'),
          ),
          body: TabBarView(
              children: [
                MainSeals_SL(),
                MainSeals_UN(),
              ]
          ),

        ),
      ),
    );
  }
}





class MainSeals_SL extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:JsonParseSealsSts_SL()
    );
  }
}

class MainSeals_UN extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:JsonParseSealsSts_UN()
    );
  }
}
