import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/HomeScreen.dart';
import '../screens/loginscreen.dart';
import '../services/botService.dart';
import '../functions/homescreenfunctions.dart';
import '../services/kideService.dart';

class eventlink {
  linkForm(_linkController, ref, context) {
    final bearer = ref.watch(bearerProvider);
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Form(
        autovalidateMode: AutovalidateMode.always,
        child: TextFormField(
          validator: (value) =>
              RegExp(r"^(https?:\/\/(.+?\.)?kide.app(\/[A-Za-z0-9\-\._~:\/\?#\[\]@!$&'\(\)\*\+,;\=]*)?)")
                      .hasMatch(value!)
                  ? null
                  : 'Not a valid Kide.App url',
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
          onChanged: (String value) =>
              ref.watch(linkProvider.notifier).update((state) => value),
          controller: _linkController,
          decoration: InputDecoration(
            prefix: _linkController.text.isEmpty
                ? null
                : InkWell(
                    child: Transform.translate(
                      offset: const Offset(-5, 5),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: const Icon(
                          Icons.highlight_remove,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () async {
                      _linkController.text = '';
                      ref.watch(eventProvider.notifier).update((state) => '');
                      ref.watch(linkProvider.notifier).update((state) => '');
                      ref.watch(timerProvider.notifier).update((state) => []);
                      await BotService().checkCart(bearer, ref);
                    },
                  ),
            suffixIcon: _linkController.text.isEmpty
                ? null
                : InkWell(
                    child: Transform.translate(
                      offset: const Offset(5, 10),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () async {
                      ref.watch(loadingProvider.notifier).update(
                          (state) => <String>[...state, 'search_event']);

                      final message = await homeFunctions()
                          .search(_linkController.text, ref);
                      ref.watch(loadingProvider.notifier).update((state) =>
                          <String>[
                            ...state
                              ..removeWhere((item) => item == 'search_event')
                          ]);
                      final snackBar = SnackBar(
                        duration: const Duration(seconds: 3),
                        content: Text(message),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            labelText: 'Paste event link here',
            labelStyle: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      ),
    );
  }
}
