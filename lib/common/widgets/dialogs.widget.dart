import 'package:flutter/material.dart';

class Dialogs {
  confirm(BuildContext context, String title, String description, Function action) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[Text(description)],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  action(context);
                },
                child: Text('Yes'),
              )
            ],
          );
        });
  }
}
