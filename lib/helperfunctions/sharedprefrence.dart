import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static String userIdKey = "USERIDKEY";
  static String userNameKey = "USERNAMEKEY";
  static String displayNameKey = "DISPLAYNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userProfilePicKey = "USERPROFILEPICKEY";

  ///Saving Information
  Future<bool> saveUserName(String userNameValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userNameKey, userNameValue);
  }

  Future<bool> saveDisplayrName(String displayNameValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(displayNameKey, displayNameValue);
  }

  Future<bool> saveUserEmail(String userEmailValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userEmailKey, userEmailValue);
  }

  Future<bool> saveUserProfilePic(String userProfilePicValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userProfilePicKey, userProfilePicValue);
  }

  Future<bool> saveUserId(String userIdValue) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.setString(userIdKey, userIdValue);
  }

  ///Getting Information
  Future<String> getUserName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userNameKey);
  }

  Future<String> getUserId() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userIdKey);
  }

  Future<String> getDisplayName() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(displayNameKey);
  }

  Future<String> getProfilePic() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userProfilePicKey);
  }

  Future<String> getUserEmail() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(userEmailKey);
  }
}
