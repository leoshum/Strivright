import 'package:app_flutter/screens/auth/dropdown.widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_flutter/common/services/user.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _email;
  String _password;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> _signIn() async {
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: _email, password: _password);
    FirebaseUser user = result.user;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropDown(),
              TextField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
              SizedBox(
                height: 15.0,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                obscureText: true,
              ),
              SizedBox(
                height: 15.0,
              ),
              RaisedButton(
                child: Text('Login'),
                color: Colors.blue,
                textColor: Colors.white,
                elevation: 7.0,
                onPressed: () {
                  _signIn().then((dynamic user) {
                    print('USER !!!!!');
                    userBlock.setUserUid(user.uid);
                    print(user.uid);
                    Navigator.of(context).pushReplacementNamed('/legacy');
                  }).catchError((dynamic error) => print(error));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
