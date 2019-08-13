import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/common/services/loader.service.dart';
import 'package:flutter_demo/common/services/user.service.dart';
import 'package:flutter_demo/common/widgets/loader.widget.dart';
import 'package:flutter_demo/screens/auth/dropdown.widget.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  String _email;
  String _password;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> _signIn(BuildContext context) async {
    loaderBlock.setLoaderState(true);
    AuthResult result = await _auth.signInWithEmailAndPassword(
        email: _email, password: _password);
    FirebaseUser user = result.user;
    return user;
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  _showSnackBar(error) {
    final snackBar = SnackBar(
      content: Text(error),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),
    );
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: StreamBuilder(
            stream: loaderBlock.isLoading,
            builder: (context, AsyncSnapshot<bool> snapshot) {
              return snapshot.data==null || !snapshot.data
                  ? Center(
                      child: Container(
                        padding: EdgeInsets.all(25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            DropDown(),
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'Email',
                                  icon: Icon(Icons.email),
                                  labelStyle: TextStyle(fontSize: 18.0)),
                              onChanged: (value) {
                                setState(() {
                                  this._email = value;
                                });
                              },
                            ),
                            TextField(
                              decoration: InputDecoration(
                                  labelText: 'Password',
                                  icon: Icon(Icons.lock),
                                  labelStyle: TextStyle(fontSize: 18.0)),
                              onChanged: (value) {
                                setState(() {
                                  this._password = value;
                                });
                              },
                              obscureText: true,
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            ButtonTheme(
                              minWidth: double.infinity,
                              height: 45.0,
                              child: RaisedButton(
                                child: Text(
                                  'Login',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                                color: Colors.blue,
                                textColor: Colors.white,
                                elevation: 7.0,
                                onPressed: () {
                                  _signIn(context).then((dynamic user) {
                                    userBlock.setUserUid(user);
                                    return Navigator.of(context)
                                        .pushReplacementNamed('/homepage');
                                  }).catchError((error) {
                                    loaderBlock.setLoaderState(false);
                                    _showSnackBar('Wrong credentials');
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Loader();
            }));
  }
}
