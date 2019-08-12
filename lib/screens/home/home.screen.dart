import 'package:app_flutter/common/services/loader.service.dart';
import 'package:app_flutter/common/widgets/timer.widget.dart';
import 'package:app_flutter/common/services/user.service.dart';
import 'package:app_flutter/common/widgets/dialogs.widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/common/services/firestore.service.dart';
import 'package:rxdart/rxdart.dart';

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
                  Padding(
                      padding:
                          EdgeInsets.only(top: 20.0, bottom: 20.0, left: 20),
                      child: Container(
                        width: 150.0,
                        height: 150.0,
                        child: isClockIn
                            ? FloatingActionButton(
                                backgroundColor: Colors.redAccent,
                                onPressed: () {
                                  dialogs.confirm(context, 'clock out',
                                      'Are you sure you want to clock out?',
                                      (context) async {
                                    DateTime now = DateTime.now();
                                    setState(() {
                                      isClockIn = false;
                                      stopwatch.stop();
                                    });
                                    String ts = stopwatch.elapsed.toString();
                                    this.lastTimer = await fireStore.setSessionEnd(
                                        snapshot.data[0].uid, now, ts, sesId);
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
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: TimerText(stopwatch: stopwatch),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: lastTimer.length > 0
                        ? Text("Last session time: $lastTimer", style: TextStyle(fontSize: 18),)
                        : Container(),
                  )
                ],
              ));
        });
  }
}
