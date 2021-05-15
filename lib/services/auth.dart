import 'package:go_bird/helperfunctions/sharedprefrence.dart';
import 'package:go_bird/services/database.dart';
import 'package:go_bird/views/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignInUser = GoogleSignIn();

    final GoogleSignInAccount _googleSignInAccountUser =
        await _googleSignInUser.signIn();

    final GoogleSignInAuthentication googleSignInAuthentication =
        await _googleSignInAccountUser.authentication;

    final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken);

    UserCredential userCredential =
        await _firebaseAuth.signInWithCredential(authCredential);

    User userDetails = userCredential.user;

    if (userCredential != null) {
      SharedPref().saveUserEmail(userDetails.email);
      SharedPref().saveDisplayrName(userDetails.displayName);
      SharedPref().saveUserId(userDetails.uid);
      SharedPref().saveUserProfilePic(userDetails.photoURL);
      SharedPref().saveUserName(userDetails.email.replaceAll("@gmail.com", ""));

      Map<String, dynamic> userInfo = {
        "email": userDetails.email,
        "username": userDetails.email.replaceAll("@gmail.com", ""),
        "name": userDetails.displayName,
        "profilePic": userDetails.photoURL
        // "userId": userDetails.uid
      };

      DatabaseMethods().addUserInfotoFirestore(userDetails.uid, userInfo).then((value) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Home()));
      });
    } else {
      //TODO Unsuccessful Login
    }
  }

  Future signOut() async{
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    sharedPref.clear();
     await auth.signOut();
  }
}
