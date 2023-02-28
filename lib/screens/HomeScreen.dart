import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidebot/functions/homescreenfunctions.dart';
import 'package:kidebot/widgets/homescreenwidgets.dart';
import 'loginscreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/botService.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../services/sharelinkService.dart';
import '../widgets/onLoading.dart';
import '../services/logoutservice.dart';
import '../widgets/eventlinkForm.dart';

final eventProvider = StateProvider<dynamic>((ref) => '');
final loadingProvider = StateProvider<List<String>>((ref) => []);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sharedlink = ref.watch(sharelinkProvider);
      if (sharedlink.length > 0) {
        _linkController.text = sharedlink;
      }
      ref.watch(linkProvider.notifier).update((state) => sharedlink);
      ref.watch(sharelinkProvider.notifier).update((state) => '');
      if (ref.watch(bearerProvider).isEmpty) {
        homeFunctions().navigateTo('/', ref, context);
      }
    });
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
      variants = homeFunctions().eventvariantsTowidgets(event);
    }

    if (reservedTickets.isNotEmpty) {
      reservedvariants =
          homeFunctions().reservedvariantsTowidgets(reservedTickets);
    }

    return Scaffold(
      appBar: AppBar(
        title: Container(
            child: Image.asset(
          'assets/images/KBBar.png',
          height: 50,
        )),
        backgroundColor: Color.fromARGB(255, 118, 83, 187),
        actions: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: TextButton(
              onPressed: () async {
                final message =
                    await homeFunctions().logout(bearer, context, ref);
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
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 94, 53, 177),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: const Color.fromARGB(255, 118, 83, 187),
        onRefresh: () async {
          ref
              .watch(loadingProvider.notifier)
              .update((state) => <String>[...state, 'search_event']);
          if (_linkController.text.length > 0) {
            final message =
                await homeFunctions().search(_linkController.text, ref);
          }
          await BotService().checkCart(bearer, ref);
          ref.watch(loadingProvider.notifier).update((state) => <String>[
                ...state..removeWhere((item) => item == 'search_event')
              ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: const Color.fromARGB(255, 94, 53, 177),
            child: SafeArea(
              child: Column(
                children: [
                  eventlink().linkForm(_linkController, ref),
                  if (_linkController.text.isNotEmpty)
                    homescreenwidgets().clearAndSearchRow(
                        ref, _linkController, bearer, context),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 118, 83, 187),
                        //color: Color.fromARGB(255, 94, 53, 177),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        boxShadow: [
                          BoxShadow(
                            color: event is Event
                                ? const Color.fromARGB(255, 0, 0, 0)
                                    .withOpacity(0.4)
                                : const Color.fromARGB(255, 0, 0, 0)
                                    .withOpacity(0.0),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: const Offset(
                                0, 0), // changes position of shadow
                          ),
                        ]),
                    child: Column(
                      children: [
                        if (event is Event)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                '${event.name}',
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                        if (event is Event && event.timeuntilsale > 0)
                          homescreenwidgets().timerWidget(event),
                        if (event is Event &&
                            reservetimer is List &&
                            reservedvariants.isEmpty)
                          homescreenwidgets()
                              .reservebuttonWidget(ref, context, link, bearer),
                        if (event is Event && reservetimer is Timer)
                          homescreenwidgets()
                              .cancelbuttonWidget(ref, context, reservetimer),
                        if (reservedvariants.isNotEmpty)
                          homescreenwidgets().kideapplinkWidget(),
                        if (reservedvariants.isNotEmpty)
                          homescreenwidgets()
                              .reservedvariantsWidget(reservedvariants),
                        if (variants.isNotEmpty)
                          homescreenwidgets().variantsWidget(variants),

                        //Text('Link: $sharedlink'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
