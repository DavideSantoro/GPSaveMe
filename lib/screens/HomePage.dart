// ignore_for_file: file_names, unnecessary_new
import 'package:first_prj/screens/AroundYou.dart';
import 'package:flutter/material.dart';
import 'package:first_prj/main.dart';
import 'package:first_prj/models/HelpCard.dart';
import 'package:flutter/services.dart';
import '../models/Status.dart';
import '../models/AlertDialogPending.dart';
import 'package:first_prj/screens/SignUpNumber.dart';
import 'package:first_prj/screens/NFC.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:shake/shake.dart';
import 'dart:async';
import '../models/User.dart';

class HomePage extends StatefulWidget {
  final String title = "GPSaveMe";
  static bool shaked = false;
  const HomePage({Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var refreshColor = const Color.fromRGBO(255, 183, 3, 1);
  List<User> users = [];
  late ShakeDetector detector;
  late Timer _timer;
  int _start = 10;

  @override
  Widget build(BuildContext context) {
    if (!Status.helpAccepted) {
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
          mainAxisAlignment: MainAxisAlignment.start,
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
                children: <Widget>[
                  Text(
                    Status.areAllFalse() ? 'Tap below or shake to ask for help ' : "Your request recap",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  ImageIcon(
                    color: Colors.white,
                    size: 37,
                  AssetImage('images/shake.jpg')
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: Status.waitingHelp ? 5 : 20)),
            if (Status.waitingHelp)
              FloatingActionButton.extended(
                  label: Row(
                    // ignore: prefer_const_literals_to_create_immutables
                    children: <Widget>[
                      const Padding(padding: EdgeInsets.only(right: 5)),
                      // ignore: prefer_interpolation_to_compose_strings
                      const Text("Refresh"),
                    ],
                  ),
                  backgroundColor: refreshColor,
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () async {
                    users = await u!.checkForHelp();
                    for (var us in users) {
                      await us.getLocation();
                      AlertDialogPending.helpers.add(us);
                    }
                    await u!.updateLocation();
                    setState(() {
                      MyApp.navigateToNextScreen(context, 0);
                    });
                  }),
            const Padding(padding: EdgeInsets.only(top: 8)),
            if (Status.areAllFalse()) ...[
              HelpCard("images/car.png", "Transportation", false),
              HelpCard("images/health.png", "Health", false),
              HelpCard("images/house.png", "House & Gardening", false),
              HelpCard("images/hands.png", "General", false),
            ] else ...[
              if (Status.waitingHelp) ...[
                FutureBuilder(
                  builder: (context, AsyncSnapshot<String> text) {
                    return const AlertDialogPending();
                  },
                  future: alertDialogPendingWrapper(),
                )
              ] else ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 8,
                  child: SizedBox(
                      width: deviceWidth / 1.1,
                      height: deviceHeight * 0.6,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Color.fromARGB(255, 158, 52, 45),
                                size: 90.0),
                            // ignore: prefer_const_constructors
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "You can't ask for help if you sent help to someone. \n\nWait for the other user to accept or reject your help request to continue.",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black38),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                )
              ]
            ]
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
              if (index == 1) {
                if (Status.areAllFalse()) {
                  await u!.updateLocation();
                  await buildRequests();
                } else if (Status.proposalAccepted) {
                  await u!.getLocation();
                }
              } else if (index == 2) {
                await u!.getReviewRating();
              }
              // ignore: use_build_context_synchronously
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
        floatingActionButton: !Status.areAllFalse()
            ? null
            : FloatingActionButton.extended(
                label: Row(
                  children: const <Widget>[
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text("Send a danger request"),
                  ],
                ),
                backgroundColor: Colors.red,
                onPressed: () {
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('DANGER REQUEST'),
                      content: const Text(
                          'Are you sure you want to send a danger request?'),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: const Color.fromRGBO(33, 158, 188, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: const Color.fromRGBO(255, 183, 3, 1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: const Text('YES'),
                              onPressed: () async => {
                                AlertDialogPending.attributes = [
                                  "Danger",
                                  "Danger request",
                                  "",
                                  "Send help as fast as possible",
                                  true,
                                ],
                                u!.uploadHelpRequest(
                                    "Danger request",
                                    "",
                                    "Send help as fast as possible",
                                    "Danger",
                                    true),
                                Status.waitingHelp = true,
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()),
                                ).then((value) => setState(() {}))
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.warning_rounded),
              ),
      );
    } else {
      return NFC(false);
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }

  @override
  void initState() {
    if (Status.areAllFalse() && !HomePage.shaked) {
      super.initState();
      detector = ShakeDetector.autoStart(onPhoneShake: () {
        if (!Status.areAllFalse()) {
          return;
        }
        var control = true;
        HapticFeedback.vibrate();
        HomePage.shaked = true;
        showDialog(
            context: context,
            builder: (context) {
              // ignore: prefer_const_constructors
              Future.delayed(Duration(seconds: 10), () {
                Navigator.of(context).pop(true);
              });
              return AlertDialog(
                  title: const Text('DANGER REQUEST'),
                  content: const Text(
                      'Are you sure you want to send a danger request?'),
                  actions: <Widget>[
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromRGBO(33, 158, 188, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            onPressed: () => {
                              control = false,
                              HomePage.shaked = false,
                              Navigator.pop(context, 'Cancel')
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: _start == 2
                                  ? const Color.fromRGBO(255, 183, 3, 1)
                                  : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                            onPressed: () => {},
                            child: Text('YES (wait $_start seconds)'),
                          )
                        ])
                  ]);
            });
        startTimer();
        Future.delayed(const Duration(milliseconds: 10000), () {
          if (control) {
            AlertDialogPending.attributes = [
              "Danger",
              "Danger request",
              "",
              "Send help as fast as possible",
              true,
            ];
            u!.uploadHelpRequest("Danger request", "",
                "Send help as fast as possible", "Danger", true);
            Status.waitingHelp = true;
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ).then((value) => setState(() {}));
            showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                      title: Text('Shaking detected'),
                      content: Text('You have sent an emergency request!'),
                    ));
            detector.stopListening();
          }
        });
        _start = 10;
      });
    }
  }

  @override
  void dispose() {
    detector.stopListening();
    _timer.cancel();
    super.dispose();
  }
}

class DropDownListWithPic extends StatefulWidget {
  const DropDownListWithPic({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DropDownListWithPicState createState() => _DropDownListWithPicState();
}

class _DropDownListWithPicState extends State<DropDownListWithPic> {
  final _img = Image.network(
      "https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/TUCPamplona10.svg/500px-TUCPamplona10.svg.png");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Test Drop"),
      ),
      // ignore: unnecessary_new
      body: new Center(
        // ignore: sized_box_for_whitespace
        child: Container(
          height: 50.0,
          child: DropdownButton(
              items: List.generate(10, (int index) {
                return DropdownMenuItem(
                    child: Container(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  height: 100.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[_img, const Text("Under 10")],
                  ),
                ));
              }),
              onChanged: null),
        ),
      ),
    );
  }
}

Future<String>? alertDialogPendingWrapper() async {
  var reqAttributes = await u!.getHelpRequest();
  AlertDialogPending.attributes = reqAttributes;
  return "done";
}
