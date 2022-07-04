// ignore_for_file: file_names, prefer_const_constructors, unrelated_type_equality_checks
import 'package:flutter/material.dart';
import 'package:first_prj/main.dart';
import '../models/NFCMethods.dart';
import '../models/Status.dart';
import 'GenerateQR.dart';
import 'GiveReview.dart';
import 'SignUpNumber.dart';

// ignore: must_be_immutable
class NFC extends StatefulWidget {
  final String title = "GPSaveMe";
  bool isTheHelper;
  // ignore: non_constant_identifier_names

  NFC(this.isTheHelper, {Key? key}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _NFC createState() => _NFC();
}

class _NFC extends State<NFC> {
  @override
  Widget build(BuildContext context) {
    // if (widget.isTheHelper) {
    //   getNFC(context);
    // } else {
    //   ndefWrite(context);
    // }
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
                  'Request accepted!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(5)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: deviceHeight * 0.05,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.black38),
                      Padding(padding: EdgeInsets.only(right: 2)),
                      Text(
                        "Please enable the NFC settings on your device",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black38),
                      ),
                    ]),
              ),
              InkWell(
                  child: SizedBox(
                    width: deviceWidth / 1.1,
                    height: deviceHeight * 0.6,
                    child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(padding: EdgeInsets.all(5)),
                            Image.asset("images/nfc.png",
                                width: deviceWidth / 2),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                  "Put your phones next to eachother to confirm you've met!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black38,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: EdgeInsets.only(
                                  right: deviceWidth / 6,
                                )),
                                Text("Or instead",
                                    style: TextStyle(
                                      color: Colors.black38,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Padding(
                                    padding: EdgeInsets.only(
                                  right: 6,
                                )),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  onPressed: () => {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                GenerateQR(widget.isTheHelper)))
                                  },
                                  child: const Text('CONFIRM WITH QR'),
                                ),
                              ],
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          right: deviceWidth / 2 - 15)),
                                  if (widget.isTheHelper) ...[
                                    Text(""),
                                  ] else ...[
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                            'Helper hasnt arrived?',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    33, 158, 188, 1)))),
                                  ]
                                ])
                          ],
                        )),
                  ),
                  onTap: () async {
                    if (widget.isTheHelper) {
                      await getNFC(context);
                      GiveReview.user = await u!.getUserForReview();
                      await u!.changeCoins(widget.isTheHelper);
                      MyApp.coins = await u!.getCoins();
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const GiveReview();
                        }),
                      ).then((value) => setState(() {}));
                    } else {
                      await ndefWrite(context);
                      GiveReview.user = await u!.getUserForReview();
                      await u!.changeCoins(widget.isTheHelper);
                      if (!mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return const GiveReview();
                        }),
                      ).then((value) => setState(() {}));
                    }
                  }),
            ],
          ),
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
