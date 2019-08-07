import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:app_flutter/common/services/user.dart';

class DrawerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return DrawerPageState();
  }
}

class DrawerPageState extends State<DrawerPage> {
  GlobalKey<SignatureState> signatureKey = GlobalKey();
  var image;
  Map<String, double> userLocation;
  @override
  void initState() {
    super.initState();
  }

  FloatingActionButton _button() {
    return FloatingActionButton(
      heroTag: 'hero4',
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
    return Scaffold(
      body: Signature(key: signatureKey),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 28.0),
        child: StreamBuilder(
          stream: userBlock.userUid,
          builder: (context, AsyncSnapshot<String> snapshot) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _button(),
                FloatingActionButton(
                  heroTag: 'hero1',
                  backgroundColor: Color.fromRGBO(34, 148, 237, 1),
                  onPressed: () {
                    info();
                  },
                  tooltip: 'Add',
                  child: Icon(Icons.help_outline, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: 'hero2',
                  backgroundColor: Color.fromRGBO(34, 148, 237, 1),
                  onPressed: () {
                    signatureKey.currentState.clearPoints();
                  },
                  tooltip: 'Add',
                  child: Text('Clear'),
                ),
                FloatingActionButton(
                  heroTag: 'hero3',
                  backgroundColor: Color.fromRGBO(34, 148, 237, 1),
                  onPressed: () {
                    setState(() {
                      image = signatureKey.currentState.rendered;
                    });
                    showImage(context, snapshot.data);
                    _getLocation()
                        .then((value) {})
                        .catchError((error) => print(error));
                    Navigator.of(context).pushReplacementNamed('/homepage');
                  },
                  tooltip: 'Add',
                  child: Text('Save'),
                ),
              ],
            );
          },
        ),
      ),
    );
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

  Future<dynamic> _getLocation() async {
    // TODO Some problems with lng, lat
    var location = Location();
    var currentLocation;
    try {
      currentLocation = await location.getLocation();
      print(currentLocation);
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
    final StorageReference ref =
        FirebaseStorage.instance.ref().child('image.png');
    final StorageUploadTask uploadTask = ref.putFile(file);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    final url = dowurl.toString();
    Firestore.instance
        .collection('users')
        .document(userId)
        .updateData({'url': url});
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
