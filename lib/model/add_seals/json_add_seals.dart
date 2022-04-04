import 'package:flutter/material.dart';
import 'package:seals_kust_agro/model/add_seals/add_seals_histiry.dart';
import 'package:seals_kust_agro/model/add_seals/service_add_seals.dart';
import 'package:seals_kust_agro/model/post/form_add_seals.dart';

class Add_Seals_list extends StatefulWidget {
  //
  Add_Seals_list() : super();


  @override
  _JsonParseSAddealsState createState() => _JsonParseSAddealsState();
}





class _JsonParseSAddealsState extends State <StatefulWidget> {

  Widget build(BuildContext context) {

    var futureBuilder = new  FutureBuilder < List<AddSeal>>(
        future: Services.getTrans(),
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

                color: Colors.greenAccent,
                margin: EdgeInsets.symmetric(vertical: 7),
                child: ListTile(
                  title: Text(
                      "${item?.seals}",
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text("${item?.info}"),
                  leading: Icon(
                    Icons.add_to_photos_outlined,
                    size: 30,
                    color: Colors.black87,
                  ),
                ),
              );

            },
          );
        }

    );
    return new Scaffold(
      appBar: AppBar( title: Text('Акт приймання/передачі пломб')),
      body:Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: futureBuilder,


      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Add_seals()),
          );
        },
        label: const Text('Створити акт'),
        icon: const Icon(Icons.add_outlined),
        backgroundColor: Colors.pink,

      ),
    );

  }

}




