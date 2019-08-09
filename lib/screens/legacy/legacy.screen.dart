import 'package:app_flutter/common/services/dialogs.service.dart';
import 'package:app_flutter/common/services/loader.service.dart';
import 'package:app_flutter/common/widgets/dialogs.widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/screens/legacy/agreement.dart';

class LegacyPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Dialogs dialogs = Dialogs();

  Future<FirebaseUser> _signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    loaderBlock.setLoaderState(false);
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
              dialogs.confirm(context, 'Signature',
                  'We need your signature on file, would you like to enter it now');
            },
          ),
          RaisedButton(
            child: Text('Disagree'),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/homepage');
            },
          )
        ],
      ),
    );
  }
}
