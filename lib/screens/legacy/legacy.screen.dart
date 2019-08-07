import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/screens/legacy/agreement.dart';

class LegacyPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> _signOut() async {
    await _auth.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Container(
        child: Text(
          terms,
          style: TextStyle(fontSize: 20.0),
        ),
      )),
      bottomNavigationBar: ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            child: Text('Agree'),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/drawer');
            },
          ),
          RaisedButton(
            child: Text('Disagree'),
            onPressed: () {
              _signOut().then((data){
                Navigator.of(context).pushReplacementNamed('/');
              });
            },
          )
        ],
      ),
    );
  }
}
