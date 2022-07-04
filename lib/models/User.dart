// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:first_prj/models/Request.dart';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class User {
  String name, surname, phoneNumber;
  bool profileCheck;
  Image imageProfile;
  String reviewMean = " ";
  double latitude;
  double longitude;
  String pendingAsk = "";
  String pendingGive = "";
  bool frontCheck = false;
  bool retroCheck = false;
  User? theOtherOne;
  User(this.name, this.surname, this.phoneNumber, this.imageProfile,
      this.profileCheck, this.latitude, this.longitude);

  getReviewRating() async {
    var jsonFile = await getCurrentData();
    num accumulator = 0;
    List reviews = jsonFile["review_list"];
    if (reviews.isNotEmpty) {
      for (int i = 0; i < reviews.length; i++) {
        accumulator += reviews[i][0];
      }
      reviewMean = (accumulator / reviews.length).toString().substring(0, 3);

      return reviewMean;
    }
    reviewMean = "0";
    return reviewMean;
  }

  double getlatitude() {
    return latitude;
  }

  double getlongitude() {
    return longitude;
  }

  static getBlankImage() async {
    final userlistPath = FirebaseStorage.instance.ref().child("blank.png");
    var url = await userlistPath.getDownloadURL();
    return Image.network(url);
  }

  updateLocation() async {
    Location location = Location();
    var position = await location.getLocation();
    latitude = position.latitude!;
    longitude = position.longitude!;
    await uploadLocation();
  }

  uploadLocation() async {
    var jsonFile = await getCurrentData();
    jsonFile["latitude"] = latitude;
    jsonFile["longitude"] = longitude;
    await uploadJson(jsonFile, "users/$phoneNumber/userdata.json", "userdata");
  }

  getLocation() async {
    var jsonFile = await getCurrentData();
    latitude = jsonFile["latitude"];
    longitude = jsonFile["longitude"];
    print("$latitude $longitude");
  }

  getCurrentData() async {
    return await downloadJson("users/$phoneNumber/userdata.json");
  }

  checkForHelp() async {
    List<User> users = [];
    final helpsPath =
        FirebaseStorage.instance.ref().child("users/$phoneNumber/");
    var helps = await helpsPath.listAll();
    for (var path in helps.items) {
      if (path.fullPath.contains("_")) {
        var jsonFile = await downloadJson(path.fullPath);
        var phone = jsonFile["phone_number"];
        final userjsonFile = await downloadJson("users/$phone/userdata.json");
        var user = await getUser(phone, userjsonFile);
        users.add(user);
      }
    }
    return users;
  }

  Future<bool> uploadHelpRequest(String type, String subType,
      String? description, String priority, bool shareNumber) async {
    await updateLocation();
    var jsonFile = await getCurrentData();
    jsonFile["waitingHelp"] = true;
    jsonFile["request_priority"] = priority;
    jsonFile["request_type"] = type;
    jsonFile["request_subtype"] = subType;
    jsonFile["request_text"] = description;
    jsonFile["share_number"] = shareNumber;
    jsonFile["latitude"] = latitude;
    jsonFile["longitude"] = longitude;

    await uploadJson(jsonFile, "users/$phoneNumber/userdata.json", "userdata");
    return true;
  }

  uploadHelpProposal(String phone) async {
    await updateLocation();
    var jsonFile = {
      "latitude": latitude,
      "longitude": longitude,
      "phone_number": phoneNumber,
      "QRCode": false
    };
    await uploadJson(jsonFile, "users/$phone/writetouser_$phoneNumber.json",
        "writetouser_$phoneNumber");
    //updating field in my own json file
    var myData = await getCurrentData();
    myData["waitingAcceptOrRefuse"] = true;
    await uploadJson(myData, "users/$phoneNumber/userdata.json", "userdata");
    return true;
  }

  getHelpRequest() async {
    var jsonFile = await getCurrentData();
    var reqType = jsonFile["request_type"];
    var reqSubType = jsonFile["request_subtype"];
    var reqText = jsonFile["request_text"];
    var shareNumber = jsonFile["share_number"];
    var priority = jsonFile["request_priority"];

    return [priority, reqType, reqSubType, reqText, shareNumber];
  }

  readHelpRequests() async {
    List<Request> requests = [];
    var usersRef = FirebaseStorage.instance.ref().child("users/");
    var usersDirs = await usersRef.listAll();
    for (var path in usersDirs.prefixes) {
      var cellPhone = path.fullPath.split("/")[1];
      if (cellPhone != phoneNumber) {
        var jsonFile = await downloadJson("users/$cellPhone/userdata.json");
        var user = await getUser(cellPhone, jsonFile);
        if (jsonFile["waitingHelp"]) {
          var request = Request(
              jsonFile["request_priority"], // needs string but is int in JSON
              jsonFile["request_type"],
              jsonFile["request_subtype"],
              jsonFile["request_text"],
              user,
              "images/${jsonFile["request_type"]}");
          requests.add(request);
        }
      }
    }
    return requests;
  }

  deleteRequest() async {
    var jsonFile = await getCurrentData();
    jsonFile["waitingHelp"] = false;
    jsonFile["helpAccepted"] = false;
    jsonFile["request_priority"] = "";
    jsonFile["request_type"] = "";
    jsonFile["request_subtype"] = "";
    jsonFile["request_text"] = "";
    jsonFile["share_number"] = false;
    jsonFile["proposalAccepted"] = false;

    await uploadJson(jsonFile, "users/$phoneNumber/userdata.json", "userdata");

    // inform the others that you don't want help anymore
    final helpsPath =
        FirebaseStorage.instance.ref().child("users/$phoneNumber/");
    var helps = await helpsPath.listAll();
    for (var path in helps.items) {
      if (path.fullPath.contains("_")) {
        var helpjsonFile = await downloadJson(path.fullPath);
        var phone = helpjsonFile["phone_number"];
        var toSend = {
          "latitude": latitude,
          "longitude": longitude,
          "phone_number": phoneNumber,
          "accepted": false,
          "rejected": true,
          "QRCode": false
        };
        await uploadJson(toSend, "users/$phone/writetouser_$phoneNumber.json",
            "writetouser_$phoneNumber");
      }
    }
    await deleteProposalFiles();
    return true;
  }

  deleteProposalFiles() async {
    final helpsPath =
        FirebaseStorage.instance.ref().child("users/$phoneNumber/");
    var helps = await helpsPath.listAll();
    for (var path in helps.items) {
      if (path.fullPath.contains("_")) {
        var proposalRef = FirebaseStorage.instance.ref().child(path.fullPath);
        proposalRef.delete();
      }
    }
  }

  acceptRequest(String phone) async {
    await updateLocation();
    var jsonFile = {
      "latitude": latitude,
      "longitude": longitude,
      "phone_number": phoneNumber,
      "accepted": true,
      "rejected": false
    };

    await uploadJson(jsonFile, "users/$phone/writetouser_$phoneNumber.json",
        "writetouser_$phoneNumber");

    //updating field in my own json file
    var myData = await getCurrentData();
    myData["waitingHelp"] = false;
    myData["helpAccepted"] = true;
    await uploadJson(myData, "users/$phoneNumber/userdata.json", "userdata");
    //deleteProposalFiles();
  }

  rejectRequest(String phone) async {
    await updateLocation();
    var jsonFile = {
      "latitude": latitude,
      "longitude": longitude,
      "phone_number": phoneNumber,
      "accepted": false,
      "rejected": true
    };
    await uploadJson(jsonFile, "users/$phone/writetouser_$phoneNumber.json",
        "writetouser_$phoneNumber");
  }

  checkProposalStatus() async {
    var incomingRef =
        FirebaseStorage.instance.ref().child("users/$phoneNumber/");
    var messages = await incomingRef.listAll();
    for (var path in messages.items) {
      if (path.fullPath.contains("_")) {
        var phone = path.fullPath.split(".")[0].split("_").last;
        var jsonFile = await downloadJson(path.fullPath);
        if (jsonFile["accepted"]) {
          var myData = await getCurrentData();
          myData["waitingAcceptOrRefuse"] = false;
          myData["proposalAccepted"] = true;
          await uploadJson(
              myData, "users/$phoneNumber/userdata.json", "userdata");

          // builda la richiesta per Riepilogo
          Request request = await buildRequest(phone);

          return [true, request];
        } else if (jsonFile["rejected"]) {
          var myData = await getCurrentData();
          myData["waitingAcceptOrRefuse"] = false;
          await uploadJson(
              myData, "users/$phoneNumber/userdata.json", "userdata");
          await deleteProposalFiles();
          return [false, false];
        }
      }
    }
    return [false, true];
  }

  buildRequest(String phone) async {
    var jsonFile = await downloadJson("users/$phone/userdata.json");
    var user = await getUser(phone, jsonFile);
    theOtherOne = user;
    await user.getLocation();

    var request = Request(
        jsonFile["request_priority"], // needs string but is int in JSON
        jsonFile["request_type"],
        jsonFile["request_subtype"],
        jsonFile["request_text"],
        user,
        "images/${jsonFile["request_type"]}");
    return request;
  }

  getUser(String phone, Map jsonFile) async {
    final userimagePath =
        FirebaseStorage.instance.ref().child("users/$phone/images/profile.jpg");
    var url = await userimagePath.getDownloadURL();
    Image profilePic = Image.network(url);
    User user = User(
        jsonFile["name"], jsonFile["surname"], phone, profilePic, true, 0, 0);
    await user.getReviewRating();
    return user;
  }

  static getDistance(User u1, User u2) {
    print("ciao eheh ${u1.latitude} ${u1.longitude}");
    print("ciao eheh2 ${u2.latitude} ${u2.longitude}");
    var userlat = u1.latitude;
    var userlon = u1.longitude;
    var reqlat = u2.latitude;
    var reqlon = u2.longitude;
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(reqlat - userlat); // deg2rad below
    var dLon = deg2rad(reqlon - userlon);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(deg2rad(userlat)) *
            cos(deg2rad(reqlat)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var d = R * c; // Distance in km
    return "${(d * 1000).round()} mt";
  }

  static double deg2rad(deg) {
    return deg * (pi / 180);
  }

  Future<bool> notifyQRCode() async {
    final helpsPath =
        FirebaseStorage.instance.ref().child("users/$phoneNumber/");
    var helps = await helpsPath.listAll();
    for (var path in helps.items) {
      if (path.fullPath.contains("_")) {
        var jsonFile = await downloadJson(path.fullPath);
        var phone = jsonFile["phone_number"];
        var helperJson = {
          "latitude": latitude,
          "longitude": longitude,
          "phone_number": phoneNumber,
          "accepted": true,
          "rejected": false,
          "QRCode": true
        };
        await uploadJson(
            helperJson,
            "users/$phone/writetouser_$phoneNumber.json",
            "writetouser_$phoneNumber");
      }
    }
    return true;
  }

  Future<bool> checkQRCode() async {
    final helpsPath =
        FirebaseStorage.instance.ref().child("users/$phoneNumber/");
    var helps = await helpsPath.listAll();
    bool qr = false;
    for (var path in helps.items) {
      if (path.fullPath.contains("_")) {
        var jsonFile = await downloadJson(path.fullPath);
        if (jsonFile.containsKey("QRCode")) {
          qr = jsonFile["QRCode"];
        }
      }
    }
    return qr;
  }

  Future<User> getUserForReview() async {
    final helpsPath =
        FirebaseStorage.instance.ref().child("users/$phoneNumber/");
    var helps = await helpsPath.listAll();
    for (var path in helps.items) {
      if (path.fullPath.contains("_")) {
        var jsonFile = await downloadJson(path.fullPath);
        var phone = jsonFile["phone_number"];
        final userimagePath = FirebaseStorage.instance
            .ref()
            .child("users/$phone/images/profile.jpg");
        var url = await userimagePath.getDownloadURL();
        Image profilePic = Image.network(url);
        var userJsonFile = await downloadJson("users/$phone/userdata.json");
        User user = User(userJsonFile["name"], userJsonFile["surname"], phone,
            profilePic, true, 0, 0);
        await user.getReviewRating();
        return user;
      }
    }
    return this;
  }

  giveReview(String text, int stars, String phone) async {
    var jsonFile = await downloadJson("users/$phone/userdata.json");
    jsonFile["review_list"].add([stars, text]);
    await uploadJson(jsonFile, "users/$phone/userdata.json", "userdata");
  }

  Future<List> getReviews() async {
    var jsonFile = await getCurrentData();
    var review_list = jsonFile["review_list"];
    return review_list.isNotEmpty ? review_list : [];


  }

  uploadJson(Map jsonFile, String path, String filename) async {
    var jsonString = jsonEncode(jsonFile);
    var bytes = utf8.encode(jsonString);
    var byteData = base64.encode(bytes);
    var arr = base64.decode(byteData);
    String tempPath = (await getTemporaryDirectory()).path;
    // crea il file nella cache
    File toupload = await File('$tempPath/$filename.json').create();
    await toupload.writeAsBytes(arr);
    final ref = FirebaseStorage.instance.ref().child(path);
    // carica il file
    ref.putFile(toupload);
  }

  downloadJson(String path) async {
    var udataRef = FirebaseStorage.instance.ref().child(path);
    const oneMegabyte = 1024 * 1024;
    final Uint8List? data = await udataRef.getData(oneMegabyte);
    var list = data!.toList();
    var jsonAsString = String.fromCharCodes(list);
    final jsonFile = await json.decode(jsonAsString);
    return jsonFile;
  }

  restoreJson() async {
    var jsonFile = await getCurrentData();
    jsonFile["waitingHelp"] = false;
    jsonFile["helpAccepted"] = false;
    jsonFile["waitingAcceptOrRefuse"] = false;
    jsonFile["proposalAccepted"] = false;
    jsonFile["request_type"] = "";
    jsonFile["request_text"] = "";
    jsonFile["request_subtype"] = "";
    jsonFile["share_number"] = false;
    jsonFile["request_priority"] = "";
    await uploadJson(jsonFile, "users/$phoneNumber/userdata.json", "userdata");
  }

  changeCoins(bool increment) async {
    var jsonFile = await getCurrentData();
    increment ? jsonFile["coins"] += 1 : jsonFile["coins"] -= 1;
    await uploadJson(jsonFile, "users/$phoneNumber/userdata.json", "userdata");
  }

  getCoins() async {
    var jsonFile = await getCurrentData();
    return jsonFile["coins"];
  }
}

class Review {
  int voto;
  String description;

  Review(this.voto, this.description);
}
