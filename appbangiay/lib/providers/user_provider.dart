import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_info.dart';

class UserProvider with ChangeNotifier {
  UserInfoModel? _user;
  UserInfoModel? get user => _user;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user_info');
    if (data != null) {
      _user = UserInfoModel.fromJson(json.decode(data));
      notifyListeners();
    }
  }

  Future<void> saveUser(UserInfoModel user) async {
    _user = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_info', json.encode(user.toJson()));
    notifyListeners();
  }

  Future<void> clearUser() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_info');
    notifyListeners();
  }
}
