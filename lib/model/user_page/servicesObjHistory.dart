import 'historyObjectListGet.dart';
import 'dart:io';
import 'dart:convert';
import  'package:seals_kust_agro/model/setting/globalvar.dart' as global;
class Services{

 static Future <List<HistrObj>> getHistrObj() async {
   try{
     HttpClient client = new HttpClient();
     client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

     final request = await client
         .getUrl(Uri.parse(global.urlVar +  '/history_object'  + '?data_area=' + global.dataArea));

         HttpClientResponse response = await request.close();
         var responseBody = await response.transform(utf8.decoder).join();




     if (200 == response.statusCode) {
       final List<HistrObj> historyObj =  ObjectHistGetFromJson(responseBody);
           return historyObj;
     } else {

       return List<HistrObj>.empty(growable: true);
           }
   } catch(e) {

     return List<HistrObj>.empty(growable: true);
   }
 }
}