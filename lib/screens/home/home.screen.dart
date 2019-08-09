import 'package:app_flutter/common/services/loader.service.dart';
import 'package:app_flutter/common/services/timer.service.dart';
import 'package:app_flutter/common/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:rxdart/rxdart.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  Map<String, double> userLocation;
  bool isClockIn = false;
  Stopwatch stopwatch = new Stopwatch();
  var _firestore = Firestore.instance;
  _setSessionStart(String userId, DateTime date) async {
    DocumentReference newDoc = await _firestore
        .collection('sessions')
        .add({"uid": userId, 'startedAt': date});
    print(newDoc.documentID);
    return newDoc.documentID;
  }

  _setSessionEnd(String userId, DateTime date, dynamic timer, sessionId) {
    _firestore
        .collection('sessions')
        .document(sessionId)
        .updateData({"uid": userId, 'finishedAt': date, 'time': timer});
  }

  _getLocation(sessionId) async {
    print(sessionId);
    LocationData currentLocation;
    Location location = new Location();
    try {
      currentLocation = await location.getLocation();
      print(currentLocation.latitude);
      _firestore.collection('sessions').document(sessionId).updateData({
        'lat': currentLocation.latitude,
        'lng': currentLocation.longitude,
      });
    } catch (e) {
      print(e);
      currentLocation = null;
    }
    return currentLocation;
  }

  var sesId;
  @override
  Widget build(BuildContext context) {
    loaderBlock.setLoaderState(false);
    return StreamBuilder(
        stream: Observable.combineLatest2(
            userBlock.userUid,
            loaderBlock.isLoading,
            (userUid, isLoading) => [userUid, isLoading]),
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
                        FirebaseAuth.instance.signOut().then((value) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }).catchError((e) {
                          print(e);
                        });
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
                            padding: EdgeInsets.all(20.0),
                            child: Container(
                              width: 150.0,
                              height: 150.0,
                              child: isClockIn
                                  ? FloatingActionButton(
                                      backgroundColor: Colors.redAccent,
                                      onPressed: () async {
                                        var now = DateTime.now();
                                        setState(() {
                                          isClockIn = false;
                                          stopwatch.stop();
                                        });
                                        var ts = stopwatch.elapsed.toString();

                                        await _setSessionEnd(
                                            snapshot.data[0], now, ts, sesId);
                                        setState(() => stopwatch.reset());
                                      },
                                      child: Text(
                                        'Clock Out',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    )
                                  : FloatingActionButton(
                                      backgroundColor: Colors.green,
                                      onPressed: () async {
                                        var now = DateTime.now();
                                        setState(() {
                                          isClockIn = true;
                                          stopwatch.start();
                                        });
                                        print(snapshot.data);
                                        sesId = await _setSessionStart(
                                            snapshot.data[0], now);
                                        print(sesId);
                                        await _getLocation(sesId);
                                      },
                                      child: Text(
                                        'Clock In',
                                        style: TextStyle(fontSize: 20.0),
                                      ),
                                    ),
                            )),
                      ]),
                  TimerText(stopwatch: stopwatch)
                ],
              ));
        });
  }
}
