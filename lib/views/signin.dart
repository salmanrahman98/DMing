import 'package:go_bird/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            AuthenticationMethods().signInWithGoogle(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Sign In",
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      ),
    );
  }
}
