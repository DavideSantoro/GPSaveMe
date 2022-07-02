// ignore_for_file: file_names
import 'dart:math';

import 'package:first_prj/models/User.dart';

class Request {
  String priority;
  String description, type, subType;
  User helped;
  String imagePath; // to instantiate when user clicks on "request help"

  Request(this.priority, this.type, this.subType, this.description, this.helped,
      this.imagePath);

  String getName() {
    return "${helped.name} ${helped.surname[0]}.";
  }

  String getPriority() {
    return priority;
  }

  @Deprecated("Use getPriority() instead")
  String getPriorityAsString() {
    return priority;
  }

  String getType() {
    return type;
  }

  String getImagePath() {
    return imagePath;
  }

  User getUser() {
    return helped;
  }

  String getDistance(userlat, userlon, reqlat, reqlon) {
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

  double deg2rad(deg) {
    return deg * (pi / 180);
  }

  String getDescription() {
    return description;
  }

  @override
  String toString() {
    return "$priority $description $type $subType";
  }
}
