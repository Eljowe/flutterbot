import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/loginscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LinkService {
  linkfill(ref, linkcontroller) async {
    final link = await ref.watch(linkProvider.notifier);
    linkcontroller.text = link;
  }
}
