import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidebot/providers.dart';
import '../screens/HomeScreen.dart';
import '../services/botService.dart';

class KideService {
  getAllEvents(ref) async {
    List<generalEvent> eventlist = [];
    const String uri =
        'https://api.kide.app/api/products?city=&productType=1&categoryId=&companyId=&pageSize=&searchText=';

    final response = await http.get(Uri.parse(uri));
    try {
      final data = jsonDecode(response.body);
      //final event = Event.fromJson(data);
      for (var obj in data['model']) {
        var event = generalEvent.fromJson(obj);
        if (event.timeuntilsale > 0) {
          eventlist.add(event);
        }
      }
      eventlist.sort((a, b) => a.timeuntilsale.compareTo(b.timeuntilsale));
      ref.watch(generalEventsProvider.notifier).update((state) => eventlist);

      return data;
    } catch (exception) {
      debugPrint('cant parse');
      return '';
    }
  }
}

class generalEvent {
  int timeuntilsale;
  String name;
  String? imageurl;
  int? availability;
  String? salestarts;
  String id;
  int favoritedTimes;
  generalEvent.fromJson(Map<String, dynamic> jsonData)
      : timeuntilsale = jsonData['timeUntilSalesStart'],
        salestarts = jsonData['dateSalesFrom'],
        name = jsonData['name'],
        imageurl = jsonData['mediaFilename'],
        availability = jsonData['availability'],
        favoritedTimes = jsonData['favoritedTimes'],
        id = jsonData['id'];
}
