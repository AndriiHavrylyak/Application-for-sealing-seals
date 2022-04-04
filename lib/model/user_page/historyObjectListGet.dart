// To parse this JSON data, do
//
//     final sealList = sealListFromJson(jsonString);

import 'dart:convert';

List<HistrObj> ObjectHistGetFromJson(String str) => List<HistrObj>.from(json.decode(str).map((x) => HistrObj.fromJson(x)));

String HistrObjToJson(List<HistrObj> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class HistrObj {
  HistrObj({
    required this.seal_number,
    required this.seals,
    required this.types,

  });

  String seal_number;
  String seals;
  String types;

  factory HistrObj.fromJson(Map<String, dynamic> json) => HistrObj(
    seal_number: json["seal_number"],
    seals: json["seals"],
    types: json["types"],
  );

  Map<String, dynamic> toJson() => {
    "seal_number": seal_number,
    "seals":seals,
    "types":types,
  };
}


//