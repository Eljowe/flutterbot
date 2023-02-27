import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'loginscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/botService.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';


final eventProvider = StateProvider<dynamic>((ref) => '');
final loadingProvider = StateProvider<bool>((ref) => false);
final reservedProvider = StateProvider((ref) => []);
final timerProvider = StateProvider<dynamic>((ref) => []);

class HomScreen extends ConsumerStatefulWidget {
  const HomScreen({Key? key}) : super(key: key);

  @override
  HomeScreen createState() => HomeScreen();
}

class HomeScreen extends ConsumerState {
  final _linkController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  _navigateTo(String link, WidgetRef ref, BuildContext ctx) {
    ctx.go(link);
  }

  _logout(String bearer, context, WidgetRef ref) async {
    await LogoutService().logout(bearer);
    ref.watch(bearerProvider.notifier).update((state) => '');
    ref.watch(informationProvider.notifier).update((state) => 'Logged out');
    ref.watch(emailProvider.notifier).update((state) => '');
    ref.watch(passWordProvider.notifier).update((state) => '');
    ref.watch(eventProvider.notifier).update((state) => '');
    ref.watch(reservedProvider.notifier).update((state) => []);
    ref.watch(loadingProvider.notifier).update((state) => false);

    _navigateTo('/', ref, context);
    return 'Logged out';
  }

  _search(String url, ref) async {
    final bearer = ref.watch(bearerProvider);
    await BotService().checkCart(bearer, ref);
    final event = await BotService().getEvent(url);
    ref.watch(eventProvider.notifier).update((state) => event);
    if (event is Event) {
      return 'searched and found';
    } else {
      return 'possibly invalid link';
    }
  }

  _reserve(String url, bearer, ref) async {
    Event thisevent = await BotService().getEvent(url);
    int time = thisevent.timeuntilsale;
    var amount_reserved = 0;
    int loops = 0;
    int variantloops = 0;
    int aheadtime = 10;
    if (time < aheadtime) {
      time=0;
    } else {
      time -= aheadtime;
    }
    Timer t = Timer(Duration(seconds: time), () async {
      while (amount_reserved == 0 && loops < 10 && variantloops < 50){
        thisevent = await BotService().getEvent(url);
        print('Variants available: ${thisevent.variants.length}');
        if (thisevent.variants.isNotEmpty){
          try {
            amount_reserved = await BotService().postCheckouts(thisevent, bearer, ref);
            if (amount_reserved > 2) {
              break;
            }
          } catch (exception ){
            print('int error');
          }
          loops++;
        }
        variantloops++;
        print("reserved: $amount_reserved, loops: $loops variantloops: $variantloops");
        await Future.delayed(Duration(seconds: 2));
      }
      ref.watch(timerProvider.notifier).update((state) => []);
      return;

    });
    ref.watch(timerProvider.notifier).update((state) => t);
    ref.watch(eventProvider.notifier).update((state) => thisevent);
    //final resp = await Future.delayed(Duration(seconds: time), () async {await BotService().postCheckouts(thisevent, bearer, ref);});
    //final resp2 = await Future.delayed(Duration(seconds: 2), () async {await BotService().checkCart(bearer, ref);});
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passWordProvider);
    final bearer = ref.watch(bearerProvider);
    final information = ref.watch(informationProvider);
    final link = ref.watch(linkProvider);
    final event = ref.watch(eventProvider);
    final isLoading = ref.watch(loadingProvider);
    final reservedTickets = ref.watch(reservedProvider);
    final reservetimer = ref.watch(timerProvider);
    final sharedlink = ref.watch(sharelinkProvider);
    List<Widget> variants = [];
    List<Widget> reservedvariants = [];
    final CountDownController _controller = CountDownController();

    if (event is Event) {
      event.variants.forEach(
        (element) => variants.add(
          SingleChildScrollView(
            child: Column(children: [
              Container(
                //color: const Color.fromARGB(255, 169, 110, 209),
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFA96ED1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: Container(
                  child: Text(element['name']),
                ),
                //Container(child: Text(element['inventoryId'])),
              ),
            ]),
          ),
        ),
      );
    }

    if (reservedTickets.isNotEmpty) {
      reservedTickets.forEach(
        (element) => reservedvariants.add(
          SingleChildScrollView(
            child: Column(children: [
              Container(
                //color: Color.fromARGB(255, 169, 110, 209),
                constraints: BoxConstraints(maxWidth: 400),
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 169, 110, 209),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(children: [
                  Container(
                    child: Text(element),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('KideBot'),
        backgroundColor: const Color.fromARGB(255, 118, 83, 187),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              final message = await _logout(bearer, context, ref);
              final snackBar = SnackBar(
                content: Text(message),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 94, 53, 177),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 94, 53, 177),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 20),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 94, 53, 177),
                      borderRadius:
                          BorderRadius.vertical(bottom: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          margin: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                          child: TextField(
                            style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                            onChanged: (String value) => ref
                                .watch(linkProvider.notifier)
                                .update((state) => value),
                            controller: _linkController,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              labelText: 'Link to the event',
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                        if (_linkController.text.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(maxWidth: 400),
                            margin: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                Container(
                                  constraints: BoxConstraints(maxWidth: 400),
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.black),
                                      ),
                                      onPressed: () async {
                                        _linkController.text = '';
                                        ref
                                            .watch(eventProvider.notifier)
                                            .update((state) => '');
                                        ref
                                            .watch(linkProvider.notifier)
                                            .update((state) => '');
                                        ref
                                            .watch(timerProvider.notifier)
                                            .update((state) => []);
                                        await BotService()
                                            .checkCart(bearer, ref);
                                      },
                                      child: Text('clear')),
                                ),
                                Spacer(),
                                Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  margin:
                                      const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.black),
                                      ),
                                      onPressed: () async {
                                        ref
                                            .watch(loadingProvider.notifier)
                                            .update((state) => true);
                                        final message =
                                            await _search(_linkController.text, ref);
                                        ref
                                            .watch(loadingProvider.notifier)
                                            .update((state) => false);
                                        final snackBar = SnackBar(
                                          content: Text(message),
                                        );
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                      },
                                      child: const Text(
                                        'Search event',
                                      )),
                                ),
                              ],
                            ),
                          ),
                        if (event is Event)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Text(
                              '${event.name}',
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (event is Event && event.timeuntilsale == 0)
                          Container(
                            margin: EdgeInsets.fromLTRB(20, 5, 20, 0),
                            padding: EdgeInsets.all(0),
                            child: const Text(
                              'Ticket sale for this event has started',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 171, 171, 171),
                                fontFamily: 'RHD',
                              ),
                            ),
                          ),
                        if (event is Event && event.timeuntilsale > 0)
                          Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 118, 83, 187),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 0, 0, 0)
                                      .withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            margin: const EdgeInsets.fromLTRB(10, 30, 10, 30),
                            padding: const EdgeInsets.all(30),
                            child: CircularCountDownTimer(
                              width: 150,
                              height: 150,
                              duration: event.timeuntilsale,
                              fillColor: Color.fromARGB(255, 118, 83, 187),
                              ringColor: Color.fromARGB(255, 63, 21, 129),
                              isReverse: true,
                              textStyle: const TextStyle(
                                fontSize: 30.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (event is Event && reservetimer is Timer)
                          InkWell(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 131, 32, 32),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.4),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.all(20),
                                padding: EdgeInsets.all(20),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                )),
                            onTap: () async {
                              ref
                                  .watch(timerProvider.notifier)
                                  .update((state) => []);
                              reservetimer.cancel();
                              ref
                                  .watch(loadingProvider.notifier)
                                  .update((state) => false);
                              const snackBar = SnackBar(
                                content: Text('Reserve process canceled'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            },
                          ),
                        if (event is Event && reservetimer is List)
                          InkWell(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 63, 21, 129),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.4),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.all(20),
                                padding: EdgeInsets.all(20),
                                child: const Text(
                                  'Reserve tickets',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                )),
                            onTap: () async {
                              ref
                                  .watch(loadingProvider.notifier)
                                  .update((state) => true);
                              const snackBar = SnackBar(
                                content: Text('Reserve process initialized'),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                              final message = await _reserve(link, bearer, ref);

                              ref
                                  .watch(loadingProvider.notifier)
                                  .update((state) => false);
                            },
                          ),
                        if (isLoading)
                          Container(
                            constraints: BoxConstraints(maxWidth: 400),
                            margin: const EdgeInsets.fromLTRB(10, 30, 10, 5),
                            child:
                                const Center(child: LinearProgressIndicator()),
                          ),
                        
                        if (reservedvariants.isNotEmpty)
                          InkWell(
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 63, 21, 129),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 0, 0, 0)
                                          .withOpacity(0.4),
                                      spreadRadius: 1,
                                      blurRadius: 1,
                                      offset: const Offset(
                                          0, 0), // changes position of shadow
                                    ),
                                  ],
                                ),
                                margin: EdgeInsets.all(20),
                                padding: EdgeInsets.all(20),
                                child: const Text(
                                  'Open Kide App cart',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                )),
                            onTap: () => launchUrl(
                              Uri.parse('https://kide.app/checkout'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                        if (reservedvariants.isNotEmpty)
                          Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 118, 83, 187),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 0, 0, 0)
                                      .withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            constraints: BoxConstraints(maxWidth: 400),
                            margin: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: const Text(
                                    'Reserved tickets:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Wrap(children: reservedvariants),
                              ],
                            ),
                          ),
                        if (variants.isNotEmpty)
                          Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 87, 58, 143),
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromARGB(255, 0, 0, 0)
                                      .withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 0), // changes position of shadow
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(maxWidth: 400),
                            margin: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: const Text(
                                    'All ticket variants for this event:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Wrap(children: variants),
                              ],
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.all(10),
                          child: Text(
                            "Logged in as $email",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Text('Link: $sharedlink'),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

