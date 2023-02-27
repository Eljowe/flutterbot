import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './screens/HomeScreen.dart';
import './screens/loginscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:window_size/window_size.dart';
import 'dart:io' show Platform;
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:async';

main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('KideBot');
    setWindowMaxSize(const Size(1000, 800));
    setWindowMinSize(const Size(1000, 800));
  }

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => SplashScreenState()),
      GoRoute(path: '/login', builder: (context, state) => LogScreen()),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomScreen(),
      )
    ],
  );

  runApp(ProviderScope(
      child: MaterialApp.router(
    routerConfig: router,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      fontFamily: 'RHD',
    ),
  )));
}

class SplashScreenState extends ConsumerStatefulWidget {
  const SplashScreenState({Key? key}) : super(key: key);

  @override
  SplashScreen createState() => SplashScreen();
}

class SplashScreen extends ConsumerState {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () => context.go('/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color.fromARGB(255, 94, 53, 177),
        child: Image.asset('assets/images/KBicon.png'));
  }
}
