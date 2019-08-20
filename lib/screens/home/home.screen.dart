import 'package:flutter_demo/common/format.date.dart';
import 'package:flutter_demo/common/services/firestore.service.dart';
import 'package:flutter_demo/common/services/loader.service.dart';
import 'package:flutter_demo/common/services/user.service.dart';
import 'package:flutter_demo/common/widgets/dialogs.widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_nfc_reader/flutter_nfc_reader.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Dialogs dialogs = Dialogs();
  Map<String, double> userLocation;
  bool isClockIn = false;
  Stopwatch stopwatch = Stopwatch();
  String sesId;
  String lastTimer = '';
  String clockInTime = '';
  String clockOutTime = '';

  @override
  void initState() {
    userBlock.user.listen((user) {
      fireStore.getUser(user.email).take(1).listen((users) {
        if (!users.documents[0]['trust']) {
          dialogs.confirm(
              context,
              'Signature',
              'We need your signature on file, would you like to enter it now',
              (context) =>
                  Navigator.of(context).pushReplacementNamed('/legacy'));
        }
      });
    });
    super.initState();
  }

  NfcData _nfcData;
  Future<void> startNFC() async {
    NfcData response;
    setState(() {
      _nfcData = NfcData();
      _nfcData.status = NFCStatus.reading;
    });

    print('NFC: Scan started');

    try {
      print('NFC: Scan readed NFC tag');
      response = await FlutterNfcReader.read();
    } catch (e) {
      print(e);
      print('NFC: Scan stopped exception');
    }
    setState(() {
      _nfcData = response;
    });
    print('NFC data $_nfcData');
  }

  Future<void> stopNFC() async {
    NfcData response;

    try {
      print('NFC: Stop scan by user');
      response = await FlutterNfcReader.stop();
    } catch (e) {
      print('NFC: Stop scan exception');
      response = NfcData(
        id: '',
        content: '',
        error: 'NFC scan stop exception',
        statusMapper: '',
      );
      response.status = NFCStatus.error;
    }

    setState(() {
      _nfcData = response;
    });
    print('NFC data $_nfcData');
  }

  @override
  Widget build(BuildContext context) {
    loaderBlock.setLoaderState(false);
    return StreamBuilder(
        stream: Observable.combineLatest2(userBlock.user, loaderBlock.isLoading,
            (user, isLoading) => [user, isLoading]),
        builder: (context, AsyncSnapshot<List> snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Home'),
                centerTitle: true,
                actions: <Widget>[
                  FlatButton(
                      child: Text('Logout',
                          style:
                              TextStyle(fontSize: 17.0, color: Colors.white)),
                      onPressed: () {
                        dialogs.confirm(
                            context,
                            'logout',
                            'Are you sure you want to log out?',
                            (context) =>
                                FirebaseAuth.instance.signOut().then((value) {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                }).catchError((e) {
                                  print(e);
                                }));
                      })
                ],
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(
                              top: 20.0, bottom: 20.0, left: 20),
                          child: Container(
                            width: 150.0,
                            height: 150.0,
                            child: isClockIn
                                ? FloatingActionButton(
                                    backgroundColor: Colors.redAccent,
                                    onPressed: () {
                                      dialogs.confirm(context, 'Clock out',
                                          'Are you sure you want to Clock out?',
                                          (context) async {
                                        DateTime now = DateTime.now();
                                        this.clockOutTime =
                                            now.toString().split('.')[0];
                                        setState(() {
                                          isClockIn = false;
                                          stopwatch.stop();
                                        });
                                        String ts =
                                            stopwatch.elapsed.toString();
                                        this.lastTimer =
                                            await fireStore.setSessionEnd(
                                                snapshot.data[0].uid,
                                                now,
                                                ts,
                                                sesId);
                                        setState(() => stopwatch.reset());
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text(
                                      'Clock Out',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  )
                                : FloatingActionButton(
                                    backgroundColor: Colors.green,
                                    onPressed: () async {
                                      DateTime now = DateTime.now();
                                      this.lastTimer = null;
                                      this.clockInTime =
                                          now.toString().split('.')[0];
                                      setState(() {
                                        isClockIn = true;
                                        stopwatch.start();
                                      });
                                      sesId = await fireStore.setSessionStart(
                                          snapshot.data[0].uid, now);
                                      await fireStore.getLocation(sesId);
                                    },
                                    child: Text(
                                      'Clock In',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                  ),
                          )),
                    ],
                  ),
                  RaisedButton(
                    child: Text(
                      "Read NFC",
                      style: (TextStyle(fontSize: 20.0)),
                    ),
                    onPressed: () {
                      startNFC();
                    },
                  ),
                  RaisedButton(
                      child: Text(
                        "Stop NFC",
                        style: (TextStyle(fontSize: 20.0)),
                      ),
                      onPressed: () {
                        stopNFC();
                      }),
                      Text(_nfcData?.content ?? ''),
                      Text(_nfcData?.error ?? ''),
                        Text(_nfcData?.statusMapper ?? ''),
                  clockInTime.length > 0
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: lastTimer == null
                              ? TextContainer(Text("Clock in at $clockInTime",
                                  style: TextStyle(fontSize: 18)))
                              : Column(
                                  children: <Widget>[
                                    TextContainer(Text(
                                        "Clock in at ${formatDate(clockInTime)}",
                                        style: TextStyle(fontSize: 18))),
                                    TextContainer(Text(
                                        "Time: ${lastTimer.split('.')[0]}",
                                        style: TextStyle(fontSize: 18))),
                                    TextContainer(Text(
                                        "Clock out at ${formatDate(clockOutTime)}",
                                        style: TextStyle(fontSize: 18))),
                                  ],
                                ),
                        )
                      : Container()
                ],
              ));
        });
  }

  Widget TextContainer(Widget txt) {
    return Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.black38,
              width: 1.0,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.black12,
                  offset: new Offset(5.0, 5.0),
                  blurRadius: 10.0),
            ],
            borderRadius: BorderRadius.circular(32.0)),
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(child: txt));
  }
}
