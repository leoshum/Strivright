import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';

class FireStore {
  var _firestore;
  FireStore(){
    this._firestore = Firestore.instance;
  }
  setSessionStart(String userId, DateTime date) async {
    DocumentReference newDoc = await _firestore
        .collection('sessions')
        .add({"uid": userId, 'startedAt': date});
    return newDoc.documentID;
  }
  setSessionEnd(String userId, DateTime date, String timer, String sessionId) {
    _firestore
        .collection('sessions')
        .document(sessionId)
        .updateData({"uid": userId, 'finishedAt': date, 'time': timer});
    return timer;
  }
  getLocation(String sessionId) async {
    LocationData currentLocation;
    Location location = Location();
    try {
      currentLocation = await location.getLocation();
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
  Stream<QuerySnapshot> getUser(String email) {
    //TODO rewrite this function
    return _firestore
        .collection('users')
        .where("email", isEqualTo: email)
        .snapshots();
  }
  Future<String> getDocId(String userId) async {
    String docId;
    await _firestore
        .collection('users')
        .where("uid", isEqualTo: userId)
        .getDocuments()
        .then((qs) => docId = qs.documents[0].documentID);
    return docId;
  }
  Future<dynamic> showImage(BuildContext context, String userId, image) async {
    final ui.Image pngBytes = await Future<ui.Image>.value(image);
    final ByteData pngBytes1 = await pngBytes.toByteData(format: ui.ImageByteFormat.png);
    Uint8List finalImage = Uint8List.view(pngBytes1.buffer);
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await File('${systemTempDir.path}/foo.png').create();
    file.writeAsBytes(finalImage);
    String docId = await getDocId(userId);
    final StorageReference ref =
    FirebaseStorage.instance.ref().child('$docId.png');
    final StorageUploadTask uploadTask = ref.putFile(file);
    var dowurl = await (await uploadTask.onComplete).ref.getDownloadURL();
    DateTime now = DateTime.now();
    final String url = dowurl.toString();
    await _firestore
        .collection('users')
        .document(docId)
        .updateData({'signUrl': url, 'createAt': now, 'trust': true});
  }
}

FireStore fireStore = FireStore();