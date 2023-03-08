import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidebot/services/kideService.dart';
import '../screens/HomeScreen.dart';
import './botService.dart';

class ImgService {
  fetchImage(Event event) async {
    final urlpath =
        "https://portalvhdsp62n0yt356llm.blob.core.windows.net/bailataan-mediaitems/";
    String uri = '${urlpath}${event.imageurl}';
    //final response = await http.get(Uri.parse(uri));
    //final decodedResponse = json.decode(response.body);
    return NetworkImage(urlpath);
  }

  fetchListImage(generalEvent event) async {
    final urlpath =
        "https://portalvhdsp62n0yt356llm.blob.core.windows.net/bailataan-mediaitems/";
    String uri = '${urlpath}${event.imageurl}';
    //final response = await http.get(Uri.parse(uri));
    //final decodedResponse = json.decode(response.body);
    return NetworkImage(urlpath);
  }
}
