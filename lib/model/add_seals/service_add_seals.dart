import 'add_seals_histiry.dart';
import 'dart:io';
import 'dart:convert';
import  'package:seals_kust_agro/model/setting/globalvar.dart' as global;
class Services{

 static Future <List<AddSeal>> getTrans() async {
   try{
     HttpClient client = new HttpClient();
     client.badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

     final request = await client
         .getUrl(Uri.parse(global.urlVar +  '/transfer_seals'  + '?data_area=' + global.dataArea));

         HttpClientResponse response = await request.close();
         var responseBody = await response.transform(utf8.decoder).join();




     if (200 == response.statusCode) {
       final List<AddSeal> trans =  AddSealFromJson(responseBody);
           return trans;
     } else {
       return List<AddSeal>.empty(growable: true); [] ;
           }
   } catch(e) {
     return List<AddSeal>.empty(growable: true);
   }
 }
}