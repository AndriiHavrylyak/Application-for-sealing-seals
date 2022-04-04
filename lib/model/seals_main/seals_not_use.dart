import 'package:flutter/material.dart';
import  'package:seals_kust_agro/model/setting/globalvar.dart' as global;
import 'dart:async';
import 'dart:io';
import 'dart:convert';
void main() => runApp(JsonParseSealsSts_UN());
class JsonParseSealsSts_UN extends StatefulWidget {

  JsonParseSealsSts_UN() : super();

  @override
  _JsonParseSealsState createState() => _JsonParseSealsState();
}

class _JsonParseSealsState extends State <StatefulWidget> {
  List<UserDetails> _searchResult = [];
  List<UserDetails> _userDetails = [];
  TextEditingController controller = new TextEditingController();


  final String url = global.urlVar +  '/seals_list'  + '?data_area=' + global.dataArea + '&status=Yes';


  // Get json result and convert it to model. Then add
  Future<Null> getUserDetails() async {


    HttpClient client = new HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);


    final request = await client
        .getUrl(Uri.parse(url))
        .timeout(Duration(seconds: 5));

    HttpClientResponse response = await request.close();


    var responseBody = await response.transform(utf8.decoder).join();


    final responseJson = json.decode(responseBody);

    setState(() {
      for (Map<String,dynamic> user in responseJson) {
        _userDetails.add(UserDetails.fromJson(user));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    getUserDetails();
  }

  Widget _buildUsersList() {
    return new ListView.builder(
      itemCount: _userDetails.length,
      itemBuilder: (context, index) {
        return new Card(
          color: (_userDetails[index].used  == "Yes") ? Colors.redAccent : Colors.greenAccent,
          margin: EdgeInsets.symmetric(vertical: 7),
          child: ListTile(
            title: Text(
              _userDetails[index].sealNumber,
              style: TextStyle(fontSize: 20),
            ),
            subtitle: Text("Використовуэться:${_userDetails[index].used}"),
            leading: Icon(
              Icons.qr_code,
              size: 30,
              color: Colors.black87,
            ),

          ),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return new ListView.builder(
      itemCount: _searchResult.length,
      itemBuilder: (context, i) {
        return new Card(
          color: (_searchResult[i].used  == "Yes") ? Colors.redAccent : Colors.greenAccent,
          margin: EdgeInsets.symmetric(vertical: 7),
          child: ListTile(
            title: Text(
              _searchResult[i].sealNumber,
              style: TextStyle(fontSize: 25),
            ),
            subtitle: Text("Використовуэться:${_searchResult[i].used}"),
            leading: Icon(
              Icons.qr_code,
              size: 30,
              color: Colors.black87,
            ),

          ),
        );
      },
    );
  }

  Widget _buildSearchBox() {

    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Card(

        child: new ListTile(
          leading: new Icon(Icons.search),
          title: new TextField(
            controller: controller,
            decoration: new InputDecoration(
                hintText: 'Пошук', border: InputBorder.none),
            onChanged: onSearchTextChanged,
          ),
          trailing: new IconButton(
            icon: new Icon(Icons.cancel),
            onPressed: () {
              controller.clear();
              onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {

    return new Scaffold(
      body:Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child:Column(
          children: <Widget>[
            new Container(
              height:80,
                color: Theme.of(context).primaryColor, child: _buildSearchBox()),
            new Expanded(
                child: _searchResult.length != 0 || controller.text.isNotEmpty
                    ? _buildSearchResults()
                    : _buildUsersList()),
          ],
        ),

      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: _buildBody()
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    _userDetails.forEach((userDetail) {
      if (userDetail.sealNumber.toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(userDetail);
    });

    setState(() {});
  }
}


class UserDetails {

  final String sealNumber, used,dataArea,dateCreated;



  UserDetails({ required   this.sealNumber, required this.used,required this.dataArea, required this.dateCreated});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return new UserDetails(
      sealNumber: json["seal_number"],
      used: json["used"],
      dataArea:json["data_area"],
      dateCreated: json["dateCreated"],

    );
  }
}







