import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidebot/providers.dart';
import '../screens/HomeScreen.dart';
import '../services/botService.dart';
import 'dart:developer';

class KideService {
  getAllEvents(ref) async {
    List<generalEvent> eventlist = [];
    const String uri =
        'https://api.kide.app/api/products?city=&productType=1&categoryId=&companyId=&pageSize=&searchText=';

    final response = await http.get(Uri.parse(uri));
    try {
      Map<String, dynamic> data = jsonDecode(response.body);
      //final event = Event.fromJson(data);
      for (var obj in data['model']) {
        var event = generalEvent.fromJson(obj);
        if (event.started == false) {
          eventlist.add(event);
        }
      }
      eventlist.sort((a, b) => a.salestarts!.compareTo(b.salestarts!));
      ref.watch(generalEventsProvider.notifier).update((state) => eventlist);

      return data;
    } catch (exception) {
      debugPrint('cant parse');
      debugPrint(exception.toString());
      return '';
    }
  }
}

class generalEvent {
  String name;
  String? imageurl;
  int? availability;
  String? salestarts;
  String id;
  bool started;
  generalEvent.fromJson(Map<String, dynamic> jsonData)
      : salestarts = jsonData['dateSalesFrom'],
        name = jsonData['name'],
        imageurl = jsonData['mediaFilename'],
        availability = jsonData['availability'],
        started = jsonData['salesStarted'],
        id = jsonData['id'];
}
