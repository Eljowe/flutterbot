import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidebot/functions/homescreenfunctions.dart';
import 'package:kidebot/widgets/eventListWidget.dart';
import 'package:kidebot/widgets/homescreenwidgets.dart';
import 'loginscreen.dart';
import '../services/botService.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'dart:async';
import '../widgets/eventlinkForm.dart';
import '../services/kideService.dart';
import 'package:html/parser.dart';
import 'dart:convert';

import '../providers.dart';

final eventProvider = StateProvider<dynamic>((ref) => '');
final loadingProvider = StateProvider<List<String>>((ref) => []);
final reservedProvider = StateProvider((ref) => []);
final timerProvider = StateProvider<dynamic>((ref) => []);
final timeuntilsaleProvider = StateProvider<int>((ref) => -1);

class HomScreen extends ConsumerStatefulWidget {
  const HomScreen({Key? key}) : super(key: key);

  @override
  HomeScreen createState() => HomeScreen();
}

class HomeScreen extends ConsumerState {
  final _linkController = TextEditingController();
  final _searchController = TextEditingController();
  List<Widget> elements = [];
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

  parsehtml(Event event) {
    final htmlString = jsonDecode(event.description)['en'];
    final document = parse(htmlString);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;
    return parsedString;
  }

  void refreshList() {
    setState(() {
      // Update the items list here
      List<generalEvent>? generalEvents = ref.watch(generalEventsProvider);
      var elements = [];
      elements = makeElements(
          generalEvents!
              .where((event) => event.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList(),
          _linkController,
          ref,
          context);
      if (elements.isEmpty) {
        elements = makeElements(generalEvents, _linkController, ref, context);
      }
      // Return a ListView widget with the items list
      return eventList(
          _searchController, _linkController, generalEvents, ref, context);
    });
  }

  Widget buildItemsList() {
    List<generalEvent>? generalEvents = ref.watch(generalEventsProvider);
    var elements = [];
    if (generalEvents != null) {
      elements = makeElements(
          generalEvents
              .where((event) => event.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList(),
          _linkController,
          ref,
          context);
      if (elements.isEmpty) {
        elements = makeElements(generalEvents, _linkController, ref, context);
      }
      return eventList(
          _searchController, _linkController, generalEvents, ref, context);
    }
    return const Text('nothing');
    // Return a ListView widget with the items list
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
    final timeuntilsale = ref.watch(timeuntilsaleProvider);

    List<Widget> variants = [];
    List<Widget> reservedvariants = [];
    final CountDownController _controller = CountDownController();

    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double safeheight = height - padding.top - padding.bottom;

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
      backgroundColor: const Color.fromARGB(255, 94, 53, 177),
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
          await KideService().getAllEvents(ref);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            color: const Color.fromARGB(255, 94, 53, 177),
            child: SafeArea(
              child: Column(
                children: [
                  eventlink().linkForm(_linkController, ref, context),
                  if (_linkController.text.isNotEmpty)
                    homescreenwidgets().clearAndSearchRow(
                        ref, _linkController, bearer, context),
                  Center(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      constraints: const BoxConstraints(maxWidth: 400),
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
                          if (event is Event && event.imageurl != null)
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 0, 0, 0)
                                        .withOpacity(0.4),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(
                                        0, 0), // changes position of shadow
                                  ),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                    "https://portalvhdsp62n0yt356llm.blob.core.windows.net/bailataan-mediaitems/${event.imageurl}"),
                              ),
                            ),

                          if (event is Event &&
                              event.availability == 0 &&
                              event.timeuntilsale == 0)
                            const Text(
                              'EVENT IS SOLD OUT',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          if (event is Event && timeuntilsale > 0)
                            homescreenwidgets().timerWidget(timeuntilsale),
                          if (event is Event &&
                              reservetimer is List &&
                              reservedvariants.isEmpty)
                            homescreenwidgets().reservebuttonWidget(
                                ref, context, link, bearer),
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
                          if (event is Event)
                            Container(
                              margin: EdgeInsets.all(20),
                              child: Text(
                                parsehtml(event),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          //Text('Link: $sharedlink'),
                          //upcoming events list
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: safeheight - 180,
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      constraints: const BoxConstraints(maxWidth: 400),
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
                          Container(
                            //event search container
                            constraints: const BoxConstraints(maxWidth: 400),
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Form(
                              child: TextFormField(
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                                controller: _searchController,
                                onChanged: (String value) => refreshList(),
                                decoration: InputDecoration(
                                  prefix: _searchController.text.isEmpty
                                      ? null
                                      : InkWell(
                                          child: Transform.translate(
                                            offset: const Offset(-5, 5),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      5, 0, 5, 0),
                                              child: const Icon(
                                                Icons.highlight_remove,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            _searchController.text = '';
                                            refreshList();
                                          },
                                        ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromARGB(255, 94, 53, 177),
                                    ),
                                  ),
                                  labelText: 'Search events',
                                  labelStyle: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          buildItemsList(),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
