import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:app_flutter/common/services/loader.service.dart';
import 'package:app_flutter/common/widgets/loader.widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:app_flutter/common/services/user.dart';
import 'package:rxdart/rxdart.dart';

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
  Map<String, double> userLocation;
  var _firestore = Firestore.instance;
  @override
  void initState() {
    super.initState();
  }

  FloatingActionButton _button() {
    return FloatingActionButton(
      backgroundColor: Color.fromRGBO(34, 148, 237, 1),
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/legacy');
      },
      tooltip: 'Add',
      child: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Observable.combineLatest2(
            userBlock.userUid,
            loaderBlock.isLoading,
            (userUid, isLoading) => [userUid, isLoading]),
        builder: (context, AsyncSnapshot<List> snapshot) {
          return Scaffold(
            body: snapshot.data[1] ? Loader() : Signature(key: signatureKey),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: snapshot.data[1]
                  ? null
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        _button(),
                        FloatingActionButton(
                          backgroundColor: Color.fromRGBO(34, 148, 237, 1),
                          onPressed: () async {
                            info();
                          },
                          tooltip: 'Add',
                          child: Icon(Icons.help_outline, color: Colors.white),
                        ),
                        FloatingActionButton(
                          backgroundColor: Color.fromRGBO(34, 148, 237, 1),
                          onPressed: () {
                            signatureKey.currentState.clearPoints();
                          },
                          tooltip: 'Add',
                          child: Text('Clear'),
                        ),
                        FloatingActionButton(
                          backgroundColor: Color.fromRGBO(34, 148, 237, 1),
                          onPressed: () {
                            loaderBlock.setLoaderState(true);
                            setState(() {
                              image = signatureKey.currentState.rendered;
                            });
                            showImage(context, snapshot.data[0]).then((data) =>
                                _getLocation(snapshot.data[0]).then((data) =>
                                    Navigator.of(context)
                                        .pushReplacementNamed('/homepage')
                                        .then((data) {
                                      loaderBlock.setLoaderState(false);
                                    })));
                          },
                          tooltip: 'Add',
                          child: Text('Save'),
                        ),
                      ],
                    ),
            ),
          );
        });
  }

  Future<void> info() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
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

  Future<String> _getDocId(userId) async {
    String docId;
    await _firestore
        .collection('users')
        .where("uid", isEqualTo: userId)
        .getDocuments()
        .then((qs) => docId = qs.documents[0].documentID);
    return docId;
  }

  Future<LocationData> _getLocation(userId) async {
    LocationData currentLocation;
    Location location = new Location();
    try {
      currentLocation = await location.getLocation();
      String docId;
      docId = await _getDocId(userId);
      _firestore.collection('users').document(docId).updateData({
        'lat': currentLocation.latitude,
        'lng': currentLocation.longitude,
        'trust': true
      });
    } catch (e) {
      print(e);
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<dynamic> showImage(BuildContext context, userId) async {
    final ui.Image pngBytes = await Future<ui.Image>.value(image);
    final pngBytes1 = await pngBytes.toByteData(format: ui.ImageByteFormat.png);
    Uint8List finalImage = Uint8List.view(pngBytes1.buffer);
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await new File('${systemTempDir.path}/foo.png').create();
    file.writeAsBytes(finalImage);
    var docId;
    docId = await _getDocId(userId);
    final StorageReference ref =
        FirebaseStorage.instance.ref().child('$docId.png');
    final StorageUploadTask uploadTask = ref.putFile(file);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var now = new DateTime.now();
    final url = dowurl.toString();
    await _firestore
        .collection('users')
        .document(docId)
        .updateData({'signUrl': url, 'createAt': now});
  }
}

class Signature extends StatefulWidget {
  Signature({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return SignatureState();
  }
}

class SignatureState extends State<Signature> {
  List<Offset> _points = <Offset>[];

  Future<ui.Image> get rendered async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    SignaturePainter painter = SignaturePainter(points: _points);
    var size = context.size;
    painter.paint(canvas, size);
    return await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GestureDetector(
          onPanUpdate: (DragUpdateDetails details) {
            setState(() {
              RenderBox _object = context.findRenderObject();
              Offset _locationPoints =
                  _object.localToGlobal(details.globalPosition);
              _points = List.from(_points)..add(_locationPoints);
            });
          },
          onPanEnd: (DragEndDetails details) {
            setState(() {
              _points.add(null);
            });
          },
          child: CustomPaint(
            painter: SignaturePainter(points: _points),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  void clearPoints() {
    setState(() {
      _points.clear();
    });
  }
}

class SignaturePainter extends CustomPainter {
  List<Offset> points = <Offset>[];

  SignaturePainter({this.points});
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 10.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate.points != points;
  }
}
