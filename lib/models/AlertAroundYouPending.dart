//import 'package:flutter/cupertino.dart';
// ignore_for_file: file_names
import 'package:first_prj/main.dart';
import 'package:flutter/material.dart';

import 'Status.dart';
//import 'package:first_prj/main.dart';
//import '../screens/HomePage.dart';
//import 'Status.dart';

class AlertAroundYouPending extends StatefulWidget {
  const AlertAroundYouPending({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AlertAroundYouPendingState createState() => _AlertAroundYouPendingState();
}

class _AlertAroundYouPendingState extends State<AlertAroundYouPending> {
  @override
  Widget build(BuildContext context) {
    return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
            SizedBox(
            width: deviceWidth/1.1,
            height: deviceHeight * 0.6,
            child: Card(
              elevation: 5,
              shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(50, 0,50, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Color.fromARGB(255, 158, 52, 45), size: 90),
                    const Text("You can't help if you have a pending help request!", 
                          textAlign: TextAlign.center, 
                          style: TextStyle(
                          fontSize: 18,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,)),
                  ],             
                ),
              )
            ),
          )],);
  }
}
