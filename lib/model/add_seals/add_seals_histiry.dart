// To parse this JSON data, do
//
//     final sealList = sealListFromJson(jsonString);

import 'dart:convert';

List<AddSeal> AddSealFromJson(String str) => List<AddSeal>.from(json.decode(str).map((x) => AddSeal.fromJson(x)));

String sealListToJson(List<AddSeal> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AddSeal {
  AddSeal({
  required this.seals,
    required this.info,

  });

  String? seals;
  String? info;


  factory AddSeal.fromJson(Map<String, dynamic> json) => AddSeal(
      seals: json["seals"],
      info: json["info"],
  );

  Map<String, dynamic> toJson() => {
    "seal_number": seals,
    "used":info,

  };
}


//