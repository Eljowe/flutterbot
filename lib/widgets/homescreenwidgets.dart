import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/HomeScreen.dart';
import '../screens/loginscreen.dart';
import '../services/botService.dart';
import '../functions/homescreenfunctions.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:url_launcher/url_launcher.dart';

class homescreenwidgets {
  clearAndSearchRow(ref, _linkController, bearer, context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Row(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 255, 125, 125)),
                ),
                onPressed: () async {
                  _linkController.text = '';
                  ref.watch(eventProvider.notifier).update((state) => '');
                  ref.watch(linkProvider.notifier).update((state) => '');
                  ref.watch(timerProvider.notifier).update((state) => []);
                  await BotService().checkCart(bearer, ref);
                },
                child: Text('clear')),
          ),
          Spacer(),
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 255, 125, 125)),
                ),
                onPressed: () async {
                  ref
                      .watch(loadingProvider.notifier)
                      .update((state) => <String>[...state, 'search_event']);
                  final message =
                      await homeFunctions().search(_linkController.text, ref);
                  ref.watch(loadingProvider.notifier).update((state) =>
                      <String>[
                        ...state..removeWhere((item) => item == 'search_event')
                      ]);
                  final snackBar = SnackBar(
                    content: Text(message),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: const Text(
                  'Search event',
                )),
          ),
        ],
      ),
    );
  }

  reservebuttonWidget(ref, context, link, bearer) {
    return InkWell(
      child: Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 158, 97, 255),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 0), // changes position of shadow
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
            .update((state) => <String>[...state, 'reserve_process']);
        const snackBar = SnackBar(
          content: Text('Reserve process initialized'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        final message = await homeFunctions().reserve(link, bearer, ref);

        try {
          ref.watch(loadingProvider.notifier).update((state) => <String>[
                ...state..removeWhere((item) => item == 'reserve_process')
              ]);
        } catch (exception) {}
      },
    );
  }

  cancelbuttonWidget(ref, context, reservetimer) {
    return InkWell(
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
                color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 0), // changes position of shadow
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
        ref.watch(timerProvider.notifier).update((state) => []);
        reservetimer.cancel();
        try {
          ref.watch(loadingProvider.notifier).update((state) => <String>[
                ...state..removeWhere((item) => item == 'reserve_process')
              ]);
        } catch (exception) {}

        const snackBar = SnackBar(
          content: Text('Reserve process canceled'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
    );
  }

  timerWidget(event) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 118, 83, 187),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      margin: const EdgeInsets.fromLTRB(10, 30, 10, 30),
      padding: const EdgeInsets.all(30),
      child: CircularCountDownTimer(
        width: 150,
        height: 150,
        duration: event.timeuntilsale,
        fillColor: const Color.fromARGB(255, 118, 83, 187),
        ringColor: const Color.fromARGB(255, 255, 125, 125),
        isReverse: true,
        textStyle: const TextStyle(
          fontSize: 30.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  reservedvariantsWidget(reservedvariants) {
    return Container(
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
            color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      constraints: BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
    );
  }

  variantsWidget(variants) {
    return Container(
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
            color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
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
    );
  }

  kideapplinkWidget() {
    return InkWell(
      child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 158, 97, 255),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 0), // changes position of shadow
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
    );
  }
}
