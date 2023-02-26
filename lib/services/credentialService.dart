import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CredentialService {
  savecredentials(ref, emailcontroller, passwordcontroller) async {
    final email = emailcontroller.text;
    final password = passwordcontroller.text;
    final rememberStatus = ref.watch(rememberProvider);
    final sharedPreferences = await SharedPreferences.getInstance();

    final checkValue = rememberStatus;
    sharedPreferences.setBool("check", checkValue);
    sharedPreferences.setString("username", email);
    sharedPreferences.setString("password", password);
    getCredent(ref, emailcontroller, passwordcontroller);
  }

  getCredent(ref, emailcontroller, passwordcontroller) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    var checkValue = sharedPreferences.getBool("check");
    if (checkValue != null) {
      if (checkValue) {
        emailcontroller.text = sharedPreferences.getString("username");
        passwordcontroller.text = sharedPreferences.getString("password");
        ref.watch(rememberProvider.notifier).update((state) => checkValue!);
        ref
            .watch(emailProvider.notifier)
            .update((state) => sharedPreferences.getString("username")!);
        ref
            .watch(passWordProvider.notifier)
            .update((state) => sharedPreferences.getString("password")!);
      } else {
        emailcontroller.clear();
        passwordcontroller.clear();
        sharedPreferences.clear();
      }
    } else {
      checkValue = false;
    }
  }

  remember() {
    print('here');
  }
}
