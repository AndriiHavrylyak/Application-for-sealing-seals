import 'package:flutter/material.dart';
import 'package:seals_kust_agro/model/post/form_unseals.dart';
import 'package:seals_kust_agro/model/post/form_seals.dart';
import  'package:seals_kust_agro/model/setting/globalvar.dart' as global;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

class JsonParseObjectSts_UN extends StatefulWidget {

  JsonParseObjectSts_UN() : super();

  @override
  _JsonParseObjectsState createState() => _JsonParseObjectsState();
}

class _JsonParseObjectsState extends State <StatefulWidget> {
  List<UserDetails> _searchResult = [];
  List<UserDetails> _userDetails = [];
  TextEditingController controller = new TextEditingController();




  final String url = global.urlVar +  '/object_status'   + '?data_area=' + global.dataArea + '&status=Ні' ;
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
          color: (_userDetails[index].sealed  == "Yes") ? Colors.redAccent : Colors.greenAccent,
          margin: EdgeInsets.symmetric(vertical: 7),
          child: ListTile(
              title: Text(
                _userDetails[index].name,
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Text("Запломбований:${_userDetails[index].sealed}"),
              leading: Icon(
                Icons.home_outlined,
                size: 30,
                color: Colors.black87,
              ),
              onTap: () =>
              {
                if ('Yes' == _userDetails[index].sealed) {
                  global.nameObj =  _userDetails[index].name,
                  global.sealsNumb = _userDetails[index].seal_number,
                  global.typesOp = 'Yes',
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Unseals()),
                  )
                }
                else{
                  {
                    global.nameObj =  _userDetails[index].name,
                    global.typesOp = 'No',
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Form_seals()),
                    )
                  }
                }
              }
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
          color: (_searchResult[i].sealed  == "Yes") ? Colors.redAccent : Colors.greenAccent,
          margin: EdgeInsets.symmetric(vertical: 7),
          child: ListTile(
              title: Text(
                _searchResult[i].name,
                style: TextStyle(fontSize: 25),
              ),
              subtitle: Text("Запломбований:${_searchResult[i].sealed}"),
              leading: Icon(
                Icons.home_outlined,
                size: 30,
                color: Colors.black87,
              ),
              onTap: () =>
              {
                if ('Yes' == _searchResult[i].sealed) {
                  global.nameObj =  _searchResult[i].name,
                  global.sealsNumb = _searchResult[i].seal_number,
                  global.typesOp = 'Yes',
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Unseals()),
                  )
                }
                else{
                  {
                    global.nameObj =  _searchResult[i].name,
                    global.typesOp = 'No',
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Form_seals()),
                    )
                  }
                }
              }
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
      if (userDetail.name.toLowerCase().contains(text.toLowerCase()))
        _searchResult.add(userDetail);
    });
    setState(() {});
  }
}



class UserDetails {

  final String name, seal_number,sealed;



  UserDetails({required this.name, required this.sealed, required this.seal_number});

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return new UserDetails(
      sealed: json['sealed'],
      name: json['name'],
      seal_number: json['seal_number'],
    );
  }
}







