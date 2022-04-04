
import 'package:flutter/material.dart';
import 'package:seals_kust_agro/model/object_main/status_object.dart';
import 'package:seals_kust_agro/model/seals_main/seals_list.dart';
import 'package:flutter/widgets.dart';
import 'package:seals_kust_agro/setting_glob.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:seals_kust_agro/model/add_seals/json_add_seals.dart';
import 'package:seals_kust_agro/model/user_page/main_page_user.dart';
import 'package:seals_kust_agro/model/setting/globalvar.dart' as global;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

Future<void> main() async {
  runApp(Main_Page(),
  );


}


class Main_Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return GetMaterialApp(
        home: HomePage());
  }
}

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}
var test;
class _HomePageState extends State<HomePage> {

  Future<bool> _onBackPressed() async {
    return await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Ви впевнині?'),
        content: new Text('Ви хочете вийти з додатку',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child:
            Text("Ні",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
          SizedBox(height: 40),
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Text("Так",
              style: TextStyle(
                fontSize: 25,
              ),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }



  int _pageIndex = 0;
  PageController? _pageController;
  final UserController c = Get.put(UserController());

  List<Widget> tabPages = [
    Login(),
    Setting(),

  ] ;
  List<Widget> loggedInTabPages = [

    UserPage(),
    Status_Obj(),
    Status_Seals(),
    Add_Seals_list(),
  ];

  @override
  void initState(){
    super.initState();
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    final UserController c = Get.put(UserController());

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Obx(() =>
      new Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: true, // <-- HERE
          showUnselectedLabels: true, // <-- AND
          currentIndex: (_pageIndex > 1 && c.nameUser.isEmpty ? 0 : _pageIndex),
          onTap: onTabTapped,
          backgroundColor: Colors.blue,
          items: <BottomNavigationBarItem>[
            if(c.nameUser.isEmpty)...[
              new BottomNavigationBarItem( icon: Icon(Icons.admin_panel_settings_outlined), title: Text(" Вхід"),backgroundColor: Colors.lightBlue),
              new BottomNavigationBarItem(icon: Icon(Icons.settings), title: Text("Налаштування"),backgroundColor: Colors.lightBlue),
            ],
            if(c.nameUser.isNotEmpty)...[
              new BottomNavigationBarItem(icon: Icon(Icons.person_pin), title: Text("Користувач"),backgroundColor: Colors.lightBlue),
              new BottomNavigationBarItem(icon: Icon(Icons.home), title: Text("Пломбування"),backgroundColor: Colors.lightBlue),
              new BottomNavigationBarItem(icon: Icon(Icons.qr_code), title: Text("Пломби"),backgroundColor: Colors.lightBlue),
              new BottomNavigationBarItem(icon: Icon(Icons.add_outlined), title: Text("Акт приймання"),backgroundColor: Colors.lightBlue),
            ]

          ],

        ),
        body: PageView(
          children: c.nameUser.isEmpty ? tabPages : loggedInTabPages,
          onPageChanged: onPageChanged,
          controller: _pageController,
        ),
      ),
      ),
    );



  }
  void onPageChanged(int page) {
    setState(() {
      this._pageIndex = page;
    });
  }

  void onTabTapped(int index) {
    this._pageController?.animateToPage(index,duration: const Duration(milliseconds: 500),curve: Curves.easeInOut);
  }
}


class Login extends StatelessWidget {



  @override
  Widget build(BuildContext context) {

    return   MaterialApp(
        home:   LoginPage(
            storage: Storage()
        )
    );
  }
}

class UserController extends GetxController {
  var nameUser = "".obs;

  void setName(String str) { nameUser.value = str; }
}

class LoginPage extends StatefulWidget {

  final Storage storage;

  LoginPage({ Key? key, required this.storage}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
//Info about users
  String? state;

  @override
  void initState() {
    super.initState();
    widget.storage.readData().then((String value) {
      setState(() {
        global.urlVar = value;
      });
    });
  }

  bool _isLoading = false;

  @override
  final UserController c = Get.find();
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            headerSection(),
            textSection(),
            buttonSection(),

          ],
        ),
      ),
    );
  }


  signIn(String login, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    var AESLogin = login;
    var AESpass = pass;
//generate a 16-byte random key
    var key = '33CC2E0DD531B761316FE91D76543ADB';

    print(key);
//encrypt
    var encryptLogin = await FlutterAesEcbPkcs5.encryptString(AESLogin, key);
    var encryptPass = await FlutterAesEcbPkcs5.encryptString(AESpass, key);




    HttpClient client = new HttpClient();
    client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);


    String url = global.urlVar + "/auth_user";

    Map map = {
      "login": encryptLogin,
      "pass": encryptPass
    };

    HttpClientRequest request = await client.postUrl(Uri.parse(url));

    request.headers.set('content-type', 'application/json');

    request.add(utf8.encode(json.encode(map)));

    HttpClientResponse response = await request.close();


    var responseBody = await response.transform(utf8.decoder).join();

    Map jsonResponse = json.decode(responseBody);

    print(jsonResponse);

    if (response.statusCode == 200) {
      if (jsonResponse['message'] ==
          '200') { //if( jsonResponse['message'] == '200') {
        setState(() {
          _isLoading = false;
        });
        final UserController c = Get.find();
        c.setName(jsonResponse['name']);
        global.nameUser = jsonResponse['name'];
        global.dataArea = jsonResponse['data_area'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserPage()),
        );
      }
      else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Error_Auth()),
        );
      }
    }

    else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed: emailController.text == "" || passwordController.text == "" ? null : () {
          setState(() {
            _isLoading = true;
          });
          signIn(emailController.text, passwordController.text);
        },
        elevation: 0.0,
        color: Colors.purple,
        child: Text("Авторизація", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }
  Container buttonSectionOut() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: RaisedButton(
        onPressed:  c.nameUser == "" ? null : () {
          c.setName("");
          global.nameUser = null;
          global.dataArea = 'Користувач не авторизований';

        },
        elevation: 0.0,
        color: Colors.purple,
        child: Text("Вихід", style: TextStyle(color: Colors.white70)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
      ),

    );
  }
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,

            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.login, color: Colors.white70),
              hintText: "Логін",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Пароль",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),

        ],
      ),

    );
  }

  Container headerSection() {
    return Container(
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 50.0),
      child: Text("Пломби",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}
class Error_Auth extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AlertDialog dialog = AlertDialog(
      title: Text('Помилка при авторизації'),
      content:
      Text('Повторити спробу авторизації'),
      actions: [
        FlatButton(
          textColor: Color(0xFF6200EE),
          onPressed: () => SystemNavigator.pop(),
          child: Text('Ні'),
        ),
        FlatButton(
          textColor: Color(0xFF6200EE),
          onPressed: () { Navigator.push(
            context,MaterialPageRoute(builder: (context) => Login()),
          );
          },
          child: Text('Так'),
        ),
      ],
    );
    return Scaffold(
        body:dialog
    );
  }
}

class Storage {
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/db.txt');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();

      return body;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> writeData(String data) async {
    final file = await localFile;
    return file.writeAsString("$data");
  }
}

