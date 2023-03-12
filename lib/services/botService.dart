import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/HomeScreen.dart';

class BotService {
  Future getEvent(String url) async {
    const String uri =
        'https://kide.app/events/86493c75-6835-45f4-87f8-d3b87ead6197';
    final productID = url.split('/').last;
    final String productURL = 'https://api.kide.app/api/products/$productID';
    final response = await http.get(Uri.parse(productURL));
    try {
      final data = jsonDecode(response.body);
      final event = Event.fromJson(data);
      return event;
    } catch (exception) {
      debugPrint('bad link');
      return '';
    }
  }

  Future postCheckouts(Event event, String bearer, ref) async {
    final information = [];
    num amount_reserved = 0;
    int loops = 0;
    final _checkoutlink = 'https://api.kide.app/api/reservations';
    final Map<String, String> headers = {
      "accept": "application/json, text/plain, */*",
      "accept-language": "fi-FI,fi;q=0.9,en-US;q=0.8,en;q=0.7",
      "authority": "api.kide.app",
      "authorization": "${bearer}",
      "content-type": "application/json;charset=UTF-8",
      "origin": "https://kide.app",
      "referer": "https://kide.app/",
      "sec-ch-ua":
          "\".Not/A)Brand\";v=\"99\", \"Google Chrome\";v=\"103\", \"Chromium\";v=\"103\"",
      "sec-ch-ua-mobile": "?0",
      "sec-ch-ua-platform": "\"Windows\"",
      "sec-fetch-dest": "empty",
      "sec-fetch-mode": "cors",
      "sec-fetch-site": "same-site",
      "user-agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36",
      "x-requested-with": "XMLHttpRequest"
    };

    for (var element in event.variants) {
      var amount = element['productVariantMaximumReservableQuantity'];
      if (element['accessControlMemberships'].isEmpty) {
        if (element['availability'] <
            element['productVariantMaximumReservableQuantity']) {
          amount = element['availability'];
        }
        debugPrint(
            "$amount: Amount of tickets available to buy for variant: ${element['name']}");
        for (amount; //element['productVariantMaximumReservableQuantity'];
            amount > 0;
            amount--) {
          final data =
              '{{"toCreate":[{{"inventoryId":"${element['inventoryId']}","quantity":${amount},"productVariantUserForm":null}}],"toCancel":[]}}';

          final response = await http.post(Uri.parse(_checkoutlink),
              headers: <String, String>{
                "accept": "application/json, text/plain, */*",
                "accept-language": "fi-FI,fi;q=0.9,en-US;q=0.8,en;q=0.7",
                "authority": "api.kide.app",
                "authorization": "${bearer}",
                "content-type": "application/json;charset=UTF-8",
                "origin": "https://kide.app",
                "referer": "https://kide.app/",
                "sec-ch-ua":
                    "\".Not/A)Brand\";v=\"99\", \"Google Chrome\";v=\"103\", \"Chromium\";v=\"103\"",
                "sec-ch-ua-mobile": "?0",
                "sec-ch-ua-platform": "\"Windows\"",
                "sec-fetch-dest": "empty",
                "sec-fetch-mode": "cors",
                "sec-fetch-site": "same-site",
                "user-agent":
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36",
                "x-requested-with": "XMLHttpRequest"
              },
              body: jsonEncode({
                "toCreate": [
                  {
                    "inventoryId": "${element['inventoryId']}",
                    "quantity": amount,
                    "productVariantUserForm": null
                  }
                ]
              }));
          if (response.statusCode == 200) {
            debugPrint('reserved $amount tickets');
            amount_reserved += amount;
            final String text = "${element['name']} tickets: $amount";
            ref
                .watch(reservedProvider.notifier)
                .update((state) => [...state, text]);
            break;
          }
        }
      }
    }
    return amount_reserved;
  }

  Future checkCart(String bearer, ref) async {
    ref.watch(reservedProvider.notifier).update((state) => []);
    try {
      const url = 'https://api.kide.app/api/reservations';
      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          "accept": "application/json, text/plain, */*",
          "accept-language": "fi-FI,fi;q=0.9,en-US;q=0.8,en;q=0.7",
          "authority": "api.kide.app",
          "authorization": "${bearer}",
          "content-type": "application/json;charset=UTF-8",
          "origin": "https://kide.app",
          "referer": "https://kide.app/",
          "sec-ch-ua":
              "\".Not/A)Brand\";v=\"99\", \"Google Chrome\";v=\"103\", \"Chromium\";v=\"103\"",
          "sec-ch-ua-mobile": "?0",
          "sec-ch-ua-platform": "\"Windows\"",
          "sec-fetch-dest": "empty",
          "sec-fetch-mode": "cors",
          "sec-fetch-site": "same-site",
          "user-agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36",
          "x-requested-with": "XMLHttpRequest"
        },
      );
      final data = jsonDecode(response.body);
      data['model']['reservations'].forEach((element) {
        final String text =
            "${element['variantName']} (tickets: ${element['reservedQuantity']})";
        ref
            .watch(reservedProvider.notifier)
            .update((state) => [...state, text]);
      });
      return data;
    } catch (exception) {
      return '';
    }
  }
}

class Event {
  int timeuntilsale;
  List variants;
  String name;
  String? imageurl;
  int? availability;
  String? salestarts;
  String description;
  Event.fromJson(Map<String, dynamic> jsonData)
      : timeuntilsale = jsonData['model']['product']['timeUntilSalesStart'],
        salestarts = jsonData['model']['product']['dateSalesFrom'],
        name = jsonData['model']['product']['name'],
        imageurl = jsonData['model']['product']['mediaFilename'],
        availability = jsonData['model']['product']['availability'],
        description = jsonData['model']['product']['description'],
        variants = jsonData['model']['variants'];
}
