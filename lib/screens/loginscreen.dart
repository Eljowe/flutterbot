import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:kidebot/services/botService.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/credentialService.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';

final emailProvider = StateProvider((ref) => '');
final passWordProvider = StateProvider((ref) => '');
final bearerProvider = StateProvider<String>((ref) => '');
final informationProvider = StateProvider<String>((ref) => '');
final rememberProvider = StateProvider<bool>((ref) => false);

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
  String? _sharedText;
  @override
  void initState() {
    super.initState();
    final sharedPreferences = SharedPreferences.getInstance();

    CredentialService().getCredent(ref, _emailController, _passwordController);
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
          setState(() {
            _sharedText = value;
            print("Shared: $_sharedText");
          });
        }, onError: (err) {
          print("getLinkStream error: $err");
        });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String? value) {
      setState(() {
        _sharedText = value;
        print("Shared: $_sharedText");
      });
    });
  }

  _navigateTo(String link, WidgetRef ref, BuildContext ctx) {
    ctx.go(link);
  }

  _login(String email, String password, context, WidgetRef ref) async {
    String bearer = await LoginService().login(email, password);
    ref.watch(bearerProvider.notifier).update((state) => bearer);
    if (bearer.isNotEmpty) {
      ref
          .watch(informationProvider.notifier)
          .update((state) => 'Login succeeded');
      _navigateTo('/home', ref, context);
      return 'Login succeeded';
    } else {
      ref.watch(informationProvider.notifier).update((state) => 'Login failed');
      return 'Login failed, check email and password';
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(emailProvider);
    final password = ref.watch(passWordProvider);
    final bearer = ref.watch(bearerProvider);
    final information = ref.watch(informationProvider);
    var login_status;
    final rememberStatus = ref.watch(rememberProvider);

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 94, 53, 177),
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 94, 53, 177),
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
                                constraints:
                                    const BoxConstraints(maxWidth: 200),
                                child: CheckboxListTile(
                                  value: rememberStatus,
                                  tileColor: Colors.white,
                                  checkColor: Colors.black,
                                  selectedTileColor: Colors.white,
                                  activeColor: Colors.white,
                                  onChanged: (bool) {
                                    ref
                                        .watch(rememberProvider.notifier)
                                        .update((state) => !state);
                                  },
                                  title: const Text(
                                    "Remember me",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              ),
                              Spacer(),
                              Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                                    onPressed: _passwordController.text.isNotEmpty && _emailController.text.isNotEmpty ? () async {
                                      await CredentialService().savecredentials(
                                          ref,
                                          _emailController,
                                          _passwordController);
                                      final message = await _login(
                                          _emailController.text,
                                          _passwordController.text,
                                          context,
                                          ref);
                                      final snackBar = SnackBar(
                                        content: Text(message),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    } : null,
                                    child: const Text('Login', style: TextStyle(color: Colors.black),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

class LoginService {
  Future login(String email, String password) async {
    const String loginpath = 'https://auth.kide.app/oauth2/token';
    final String payload =
        'client_id=56d9cbe22a58432b97c287eadda040df&grant_type=password&password=${password}&rememberMe=true&username=${email}';
    var response = await http.post(Uri.parse('$loginpath'), body: payload);
    var data = jsonDecode(response.body);
    if (data['access_token'] != null) {
      final token = "Bearer ${data['access_token']}";
      return token;
    }
    return '';
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
