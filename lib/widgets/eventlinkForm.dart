import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/HomeScreen.dart';
import '../screens/loginscreen.dart';

class eventlink {
  linkForm(_linkController, ref) {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
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
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 2,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            labelText: 'Paste event link here',
            labelStyle: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
        ),
      ),
    );
  }
}
