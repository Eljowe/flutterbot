import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kidebot/functions/loginscreenfunctions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/credentialService.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'HomeScreen.dart';
import '../widgets/onLoading.dart';

final linkProvider = StateProvider<String>((ref) => '');
final emailProvider = StateProvider((ref) => '');
final passWordProvider = StateProvider((ref) => '');
final bearerProvider = StateProvider<String>((ref) => '');
final informationProvider = StateProvider<String>((ref) => '');
final rememberProvider = StateProvider<bool>((ref) => false);
final sharelinkProvider = StateProvider<dynamic>((ref) => '');

final sharedPrefs = FutureProvider<SharedPreferences>(
    (_) async => await SharedPreferences.getInstance());

class LogScreen extends ConsumerStatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  LoginScreen createState() => LoginScreen();
}

class LoginScreen extends ConsumerState {
  late StreamSubscription _intentDataStreamSubscription;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _sharedText = '';
  @override
  void initState() {
    super.initState();
    final sharedPreferences = SharedPreferences.getInstance();

    CredentialService().getCredent(ref, _emailController, _passwordController);
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value.split(' ').last;
        ref.watch(linkProvider.notifier).update((state) => _sharedText);
      });
    }, onError: (err) {
      debugPrint("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        if (value is String) {
          _sharedText = value.split(' ').last;
          ref.watch(linkProvider.notifier).update((state) => _sharedText);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passWordProvider);
    final bearer = ref.watch(bearerProvider);
    final information = ref.watch(informationProvider);
    var login_status;
    final rememberStatus = ref.watch(rememberProvider);
    final isLoading = ref.watch(loadingProvider);
    final link = ref.watch(linkProvider);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 53, 177),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 94, 53, 177),
          child: SafeArea(
            child: Column(
              children: [
                Stack(children: [
                  Center(
                    child: Container(
                        child: Image.asset(
                      'assets/images/KBicon.png',
                      height: 300,
                    )),
                  ),
                  if (isLoading.isNotEmpty)
                    Positioned.fill(
                      top: 220,
                      child: onLoading().loadingAnimation(),
                    ),
                ]),
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
                          padding: EdgeInsets.all(20),
                          child: const Text(
                            'KideBot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          constraints: BoxConstraints(maxWidth: 400),
                          margin: EdgeInsets.all(10),
                          child: Form(
                            autovalidateMode: AutovalidateMode.always,
                            child: TextFormField(
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255)),
                              validator: validateEmail,
                              onChanged: (String value) => ref
                                  .watch(emailProvider.notifier)
                                  .update((state) => value),
                              controller: _emailController,
                              decoration: const InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextFormField(
                            style: const TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                            onChanged: (String value) => ref
                                .watch(passWordProvider.notifier)
                                .update((state) => value),
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                height: 50,
                                constraints:
                                    const BoxConstraints(maxWidth: 180),
                                child: CheckboxListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  value: rememberStatus,
                                  tileColor: Colors.white,
                                  checkColor: Colors.white,
                                  selectedTileColor: Colors.white,
                                  activeColor:
                                      Color.fromARGB(255, 255, 125, 125),
                                  onChanged: (bool) {
                                    ref
                                        .watch(rememberProvider.notifier)
                                        .update((state) => !state);
                                  },
                                  title: Transform.translate(
                                    offset: const Offset(-10, 0),
                                    child: const Text(
                                      "Remember me",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 255, 125, 125)),
                                    onPressed: _passwordController
                                                .text.isNotEmpty &&
                                            _emailController.text.isNotEmpty
                                        ? () async {
                                            ref
                                                .watch(loadingProvider.notifier)
                                                .update((state) => [
                                                      ...state,
                                                      'login_process'
                                                    ]);
                                            if (_sharedText is String) {
                                              if (_sharedText.isNotEmpty) {
                                                ref
                                                    .watch(sharelinkProvider
                                                        .notifier)
                                                    .update(
                                                        (state) => _sharedText);
                                                _sharedText = '';
                                              }
                                            }
                                            await CredentialService()
                                                .savecredentials(
                                                    ref,
                                                    _emailController,
                                                    _passwordController);

                                            final message =
                                                await loginScreenFunctions()
                                                    .login(
                                                        _emailController.text,
                                                        _passwordController
                                                            .text,
                                                        context,
                                                        ref);
                                            ref
                                                .watch(loadingProvider.notifier)
                                                .update((state) => [
                                                      ...state
                                                        ..removeWhere((item) =>
                                                            item ==
                                                            'login_process')
                                                    ]);
                                            final snackBar = SnackBar(
                                              content: Text(message),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackBar);
                                          }
                                        : null,
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //Text("link: $_sharedText"),
                        //Text(email),
                        //Text(password),
                        //Text("Remember: $rememberStatus"),
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

String? validateEmail(String? value) {
  const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
  final regex = RegExp(pattern);

  return value!.isNotEmpty && !regex.hasMatch(value)
      ? 'Enter a valid email address'
      : null;
}
