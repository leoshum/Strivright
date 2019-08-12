import 'package:app_flutter/common/services/loader.service.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/screens/legacy/agreement.dart';

class LegacyPage extends StatelessWidget {
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
              Navigator.of(context).pushReplacementNamed('/drawer');
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
