import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey,
        appBar: AppBar(
          title:
          Center(
              child: Text("HI",
              style: TextStyle(
                color: Colors.black,
              ),)),
          backgroundColor: Colors.black26,
        ),
        body: Center(
          child: Image(image: AssetImage('images/logo-mysql-mysql-and-moodle-elearningworld-5.png')),
        ))
  ),
  );
}
