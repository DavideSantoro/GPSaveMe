// ignore_for_file: file_names, prefer_const_constructors, unrelated_type_equality_checks
import 'package:first_prj/screens/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:first_prj/main.dart';

import '../models/Status.dart';
import '../models/User.dart';
import 'SignUpNumber.dart';

class GiveReview extends StatefulWidget {
  final String title = "GPSaveMe";
  static User? user;
  // ignore: non_constant_identifier_names
  const GiveReview({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _GiveReview createState() => _GiveReview();
}

class _GiveReview extends State<GiveReview> {
  var review = "";
  List<bool> stars = [false, false, false, false, false];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(widget.title,
            textAlign: TextAlign.left, style: const TextStyle(fontSize: 25)),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Tooltip(
                  message: "Remaining coins to ask for help!",
                  triggerMode: TooltipTriggerMode.tap,
                  child: Icon(Icons.diamond_sharp),
                ),
                Text(MyApp.coins.toString()),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 60.0,
            decoration: const BoxDecoration(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(15.0)),
              color: Color.fromRGBO(142, 202, 230, 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                Text(
                  'Leave a review!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: EdgeInsets.only(top: deviceHeight * 0.035)),
          Card(
            elevation: 3,
            margin: EdgeInsets.all(8.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              // ignore: prefer_const_literals_to_create_immutables
              Padding(padding: EdgeInsets.only(bottom: deviceHeight* 0.02),),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40.0),
                        child: GiveReview.user!.imageProfile,
                      ),
                    ),
                  Text("${GiveReview.user!.name} ${GiveReview.user!.surname}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ))
                ],
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, deviceHeight * 0.005, 0, deviceHeight * 0.005)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var i = 0; i < 5; i++)
                  IconButton(
                    icon: Icon(Icons.star),
                    iconSize: deviceHeight * 0.042,
                    color: stars[i]
                        ? Color.fromARGB(255, 244, 197, 11)
                        : Colors.grey,
                    onPressed: () => {
                      setState(() {
                        stars = [false, false, false, false, false];
                        for (int j = 0; j <= i; j++) {
                          stars[j] = !stars[j];
                        }
                      })
                    },
                  )
              ]),
             
              Padding(padding: EdgeInsets.all(deviceWidth*0.03), child:TextField(
                  maxLines: 6,
                
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    labelText: 'Write your feedback here...',
                  ),
                  onChanged: (value) {
                    setState(() {
                      review = value;
                    });
                  })),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, deviceHeight * 0.025, 0, deviceHeight * 0.025)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: review == "" ? Colors.grey : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () async {
                   showDialog( 
                    context: context,
                    barrierDismissible: false, // user must tap button!
                    builder: (BuildContext context) {
                      return AlertDialog(
                        
                        title: const Text('Yay! 🎉'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: const <Widget>[
                              Text('You successfully gave your review!'),
                              Text(""),
                              Text('You\'re now able to go back to the homepage.\nThank you for your collaboration!'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                           ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                                    
                            child: const Text('Back Home'),
                            onPressed: () {
                                          
                            MyApp.selectedIndex = 0;
                            MyApp.navigateToNextScreen(context, 0);
                            },
                          ),
                        ],
                      );
                  },);
                  int res = stars
                      .map((element) => element ? 1 : 0)
                      .reduce((value, element) => value + element);
                  await u!
                      .giveReview(review, res, GiveReview.user!.phoneNumber);
                  Status.setAllFalse();
                  await u!.deleteProposalFiles();
                  await u!.restoreJson();
                  if (!mounted) return;
                 
                  //u!.deleteRequest();
                },
                child: const Text('SEND REVIEW'),
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, deviceHeight * 0.025, 0, deviceHeight * 0.025)),
            ]),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromRGBO(255, 183, 3, 1),
        selectedItemColor: const Color.fromRGBO(33, 158, 188, 1),
        unselectedItemColor: Colors.white,
        currentIndex: MyApp.selectedIndex,
        onTap: (index) async {
          if (MyApp.selectedIndex != index) {
            setState(() {
              MyApp.selectedIndex = index;
            });
            MyApp.navigateToNextScreen(context, index);
          }
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.gps_fixed), label: 'Around You'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
        ],
      ),
    );
  }
}
