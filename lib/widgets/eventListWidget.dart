import 'package:flutter/material.dart';
import 'package:kidebot/functions/homescreenfunctions.dart';
import 'package:intl/intl.dart';
import '../services/kideService.dart';
import '../screens/HomeScreen.dart';
import '../screens/loginscreen.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
                      width: 150,
                      height: 85,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 38, 13, 48),
                      ),
                      child: Image.network(
                          "https://portalvhdsp62n0yt356llm.blob.core.windows.net/bailataan-mediaitems/${element.imageurl}"),
                    ),
                    Container(
                      height: 85,
                      width: 200,
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 255, 255, 255)),
                      child: Center(
                        child: AutoSizeText.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text:
                                      '${element.name} | Ticket sale: ${DateFormat('dd.MM. kk:mm').format(DateTime.parse(element.salestarts!.split(':').first))} | ${element.favoritedTimes} 💜'),
                            ],
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
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
        Container(
          margin: const EdgeInsets.all(10),
          child: const Text(
            'Upcoming events',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400, minHeight: 100),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: elements.length,
            itemBuilder: (context, index) {
              return elements[index];
            },
          ),
        )
      ]));
}
