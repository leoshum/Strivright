import 'dart:async';
import 'package:app_flutter/common/services/firestore.service.dart';
import 'package:app_flutter/common/services/loader.service.dart';
import 'package:app_flutter/common/widgets/loader.widget.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/common/services/user.service.dart';
import 'package:rxdart/rxdart.dart';
import 'signature.screen.dart';

class DrawerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DrawerPageState();
  }
}

class DrawerPageState extends State<DrawerPage> {
  GlobalKey<SignatureState> signatureKey = GlobalKey();
  bool loader = false;
  var image;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Observable.combineLatest2(userBlock.user, loaderBlock.isLoading,
            (user, isLoading) => [user, isLoading]),
        builder: (context, AsyncSnapshot<List> snapshot) {
          return snapshot.data is List
              ? Scaffold(
                  body: snapshot.data[1]
                      ? Loader()
                      : Signature(key: signatureKey),
                  floatingActionButton: Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: snapshot.data[1]
                        ? null
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FloatingActionButton(
                                backgroundColor:
                                    Color.fromRGBO(34, 148, 237, 1),
                                heroTag: 'hero4',
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/legacy');
                                },
                                tooltip: 'Add',
                                child: Icon(Icons.arrow_back),
                              ),
                              FloatingActionButton(
                                backgroundColor:
                                    Color.fromRGBO(34, 148, 237, 1),
                                heroTag: 'hero1',
                                onPressed: () async {
                                  info();
                                },
                                tooltip: 'Add',
                                child: Icon(Icons.help_outline,
                                    color: Colors.white),
                              ),
                              FloatingActionButton(
                                heroTag: 'hero2',
                                backgroundColor:
                                    Color.fromRGBO(34, 148, 237, 1),
                                onPressed: () {
                                  signatureKey.currentState.clearPoints();
                                },
                                tooltip: 'Add',
                                child: Text('Clear'),
                              ),
                              FloatingActionButton(
                                heroTag: 'hero3',
                                backgroundColor:
                                    Color.fromRGBO(34, 148, 237, 1),
                                onPressed: () {
                                  loaderBlock.setLoaderState(true);
                                  setState(() {
                                    image = signatureKey.currentState.rendered;
                                  });
                                  fireStore.showImage(context, snapshot.data[0].uid, image).then(
                                      (data) => Navigator.of(context)
                                          .pushReplacementNamed('/homepage'));
                                },
                                tooltip: 'Add',
                                child: Text('Save'),
                              ),
                            ],
                          ),
                  ),
                )
              : Loader();
        });
  }

  Future<void> info() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Draw your signature'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Please use your finger to draw your signature on the screen'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Got it'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
