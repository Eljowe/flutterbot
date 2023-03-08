import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/HomeScreen.dart';
import '../screens/loginscreen.dart';
import 'package:go_router/go_router.dart';
import '../services/botService.dart';
import '../services/credentialService.dart';
import '../services/sharelinkService.dart';
import 'dart:async';
import '../services/logoutservice.dart';
import '../services/kideService.dart';

class loginScreenFunctions {
  navigateTo(String link, WidgetRef ref, BuildContext ctx) {
    ctx.go(link);
  }

  login(String email, String password, context, WidgetRef ref) async {
    String bearer = await LoginService().login(email, password);
    ref.watch(bearerProvider.notifier).update((state) => bearer);
    if (bearer.isNotEmpty) {
      ref
          .watch(informationProvider.notifier)
          .update((state) => 'Login succeeded');
      await KideService().getAllEvents(ref);
      navigateTo('/home', ref, context);
      return 'Login succeeded';
    } else {
      ref.watch(informationProvider.notifier).update((state) => 'Login failed');
      return 'Login failed, check email and password';
    }
  }
}

class LoginService {
  Future login(String email, String password) async {
    const String loginpath = 'https://auth.kide.app/oauth2/token';
    final String payload =
        'client_id=56d9cbe22a58432b97c287eadda040df&grant_type=password&password=${password}&rememberMe=true&username=${email}';
    var response = await http.post(Uri.parse('$loginpath'), body: payload);
    var data = jsonDecode(response.body);
    if (data['access_token'] != null) {
      final token = "Bearer ${data['access_token']}";
      return token;
    }
    return '';
  }
}
