import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: 100,
      height: 100,
      child: CircularProgressIndicator(
        backgroundColor: Colors.white,
      ),
    ));
  }
}
