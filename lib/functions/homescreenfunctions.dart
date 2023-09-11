import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/HomeScreen.dart';
import '../screens/loginscreen.dart';
import 'package:go_router/go_router.dart';
import '../services/botService.dart';
import 'dart:async';
import '../services/logoutservice.dart';

class homeFunctions {
  navigateTo(String link, WidgetRef ref, BuildContext ctx) {
    ctx.go(link);
  }

  logout(String bearer, context, WidgetRef ref) async {
    await LogoutService().logout(bearer);
    ref.watch(bearerProvider.notifier).update((state) => '');
    ref.watch(informationProvider.notifier).update((state) => 'Logged out');
    ref.watch(emailProvider.notifier).update((state) => '');
    ref.watch(passWordProvider.notifier).update((state) => '');
    ref.watch(eventProvider.notifier).update((state) => '');
    ref.watch(reservedProvider.notifier).update((state) => []);
    ref.watch(loadingProvider.notifier).update((state) => []);

    navigateTo('/', ref, context);
    return 'Logged out';
  }

  search(String url, ref) async {
    final bearer = ref.watch(bearerProvider);
    await BotService().checkCart(bearer, ref);
    final event = await BotService().getEvent(url);
    ref.watch(eventProvider.notifier).update((state) => event);
    DateTime now = DateTime.now();
    DateTime upcoming = DateTime.parse(event.salestarts!);
    Duration difference = upcoming.difference(now);
    int seconds = difference.inSeconds;
    ref.watch(timeuntilsaleProvider.notifier).update((state) => seconds);
    if (event is Event) {
      return 'searched and found';
    } else {
      return 'possibly invalid link';
    }
  }

  reserve(String url, bearer, ref) async {
    Event thisevent = await BotService().getEvent(url);
    DateTime now = DateTime.now();
    DateTime upcoming = DateTime.parse(thisevent.salestarts!);
    Duration difference = upcoming.difference(now);
    int seconds = difference.inSeconds;
    int time = thisevent.timeuntilsale;
    var amount_reserved = 0;
    int loops = 0;
    int variantloops = 0;
    int aheadtime = 4;
    if (seconds is int) {
      time = seconds;
    }
    if (time < aheadtime) {
      time = 0;
    } else {
      time -= aheadtime;
    }
    Timer t = Timer(Duration(seconds: time), () async {
      while (amount_reserved == 0 && loops < 80 && variantloops < 80) {
        thisevent = await BotService().getEvent(url);
        debugPrint('Variants available: ${thisevent.variants.length}');
        if (thisevent.variants.isNotEmpty) {
          try {
            amount_reserved =
                await BotService().postCheckouts(thisevent, bearer, ref);
            if (amount_reserved > 0) {
              break;
            }
          } catch (exception) {
            debugPrint('int error at homescreenfunctions');
            debugPrint(exception.toString());
          }
          loops++;
        } else {
          variantloops++;
        }
        debugPrint("ticket available loops (max 80): $loops");
        debugPrint("tickets unavailable loops (max 80): $variantloops");
        debugPrint("reserved: $amount_reserved");
        await Future.delayed(const Duration(seconds: 1));
      }
      ref.watch(timerProvider.notifier).update((state) => []);
      return;
    });
    ref.watch(timerProvider.notifier).update((state) => t);
    ref.watch(eventProvider.notifier).update((state) => thisevent);
    //final resp = await Future.delayed(Duration(seconds: time), () async {await BotService().postCheckouts(thisevent, bearer, ref);});
    //final resp2 = await Future.delayed(Duration(seconds: 2), () async {await BotService().checkCart(bearer, ref);});
  }

  eventvariantsTowidgets(event) {
    List<Widget> variants = [];
    event.variants.forEach(
      (element) => variants.add(
        Column(children: [
          Container(
            //color: const Color.fromARGB(255, 169, 110, 209),
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 59, 52, 61),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
            ),
            child: Container(
              child: Text(
                "${element['name']} | available tickets: ${element['availability']}",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            //Container(child: Text(element['inventoryId'])),
          ),
        ]),
      ),
    );
    return variants;
  }

  reservedvariantsTowidgets(reservedTickets) {
    List<Widget> reservedvariants = [];
    reservedTickets.forEach(
      (element) => reservedvariants.add(
        Column(children: [
          Container(
            //color: Color.fromARGB(255, 169, 110, 209),
            constraints: BoxConstraints(maxWidth: 400),
            margin: EdgeInsets.all(5),
            padding: EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 59, 52, 61),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5)),
            ),
            child: Column(children: [
              Container(
                child: Text(
                  element,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
    return reservedvariants;
  }
}
