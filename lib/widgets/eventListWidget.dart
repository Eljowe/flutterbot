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
                _linkController.text = '';
                ref.watch(eventProvider.notifier).update((state) => '');
                ref.watch(linkProvider.notifier).update((state) => '');
                ref.watch(timerProvider.notifier).update((state) => []);
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
                  duration: Duration(seconds: 1),
                  content: Text(message),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
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
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Container(
                          height: 85,
                          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255)),
                          child: Center(
                            child: AutoSizeText(
                              '${element.name} | Ticket sale: ${DateFormat('dd.MM. kk:mm').format(DateTime.parse(element.salestarts!).add(Duration(hours: 3)))}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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

  double height = MediaQuery.of(context).size.height;
  var padding = MediaQuery.of(context).padding;
  double safeheight = height - padding.top - padding.bottom;
  //var elements = makeElements(generalEvents, ref, context);
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
        constraints:
            BoxConstraints(maxHeight: safeheight - 345, minHeight: 100),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: elements.length,
          itemBuilder: (context, index) {
            return elements[index];
          },
        ),
      )
    ]),
  );
}
