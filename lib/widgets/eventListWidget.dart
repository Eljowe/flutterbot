import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidebot/functions/homescreenfunctions.dart';
import 'package:kidebot/widgets/homescreenwidgets.dart';
import '../services/botService.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../widgets/eventlinkForm.dart';
import '../services/imgService.dart';
import '../providers.dart';
import '../services/kideService.dart';
import '../screens/HomeScreen.dart';
import '../screens/loginscreen.dart';

makeElements(
    List<generalEvent> generalEventList, _linkController, ref, context) {
  List<Widget> eventItems = [];
  //List<generalEvent>? generalEventList = ref.watch(generalEventsProvider);

  if (generalEventList.runtimeType != null) {
    generalEventList.forEach((element) => {
          eventItems.add(
            InkWell(
              onTap: () async {
                await ref
                    .watch(linkProvider.notifier)
                    .update((state) => "https://kide.app/events/${element.id}");
                _linkController.text = "https://kide.app/events/${element.id}";
                ref
                    .watch(loadingProvider.notifier)
                    .update((state) => <String>[...state, 'search_event']);

                final message =
                    await homeFunctions().search(_linkController.text, ref);
                ref.watch(loadingProvider.notifier).update((state) => <String>[
                      ...state..removeWhere((item) => item == 'search_event')
                    ]);
                final snackBar = SnackBar(
                  duration: Duration(seconds: 3),
                  content: Text(message),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Row(
                  children: [
                    Container(
                      width: 180,
                      height: 100,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 38, 13, 48)),
                      child: Image.network(
                          "https://portalvhdsp62n0yt356llm.blob.core.windows.net/bailataan-mediaitems/${element.imageurl}"),
                    ),
                    Container(
                      width: 170,
                      height: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255)),
                      child: Center(
                        child: Column(children: [
                          Center(
                            child: Text(
                              '${element.name}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Center(
                            child: Text(
                              "Ticket sale: ${DateFormat('dd.MM. kk:mm').format(DateTime.parse(element.salestarts!.split(':').first))}",
                              style: const TextStyle(),
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        });
  }
  return eventItems;
}

eventList(_searchController, _linkController, List<generalEvent> generalEvents,
    ref, context) {
  List<Widget> elements = makeElements(
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
  //var elements = makeElements(generalEvents, ref, context);
  return Container(
      padding: const EdgeInsets.all(20),
      child: Column(children: <Widget>[
        const Text(
          'Upcoming events',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 330, minHeight: 100),
          child: ListView(
            shrinkWrap: true,
            children: [
              ...elements,
            ],
          ),
        )
      ]));
}
