import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutService {
  Future logout(String bearer) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': bearer
    };
    const String logoutpath =
        'https://api.kide.app/api/authentication/deauthenticate';
    var response =
        await http.post(Uri.parse(logoutpath), headers: requestHeaders);
  }
}
