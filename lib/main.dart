import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './screens/HomeScreen.dart';
import './screens/loginscreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:window_size/window_size.dart';
import 'dart:io' show Platform;

main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('KideBot');
    setWindowMaxSize(const Size(600, 900));
    setWindowMinSize(const Size(600, 900));
  }

  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => LogScreen()),
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
