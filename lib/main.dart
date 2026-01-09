import 'dart:io';
import 'package:vivant/domain/constants/constants.dart';
import 'package:vivant/utils/firebase.dart';
import 'package:vivant/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:vivant/screens/home_screen.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Adjust logging output as needed while developing
  Logger.globalLevel = LogLevel.verbose;
  Logger.globalPrefix = Constants.strings.appSlug;
  Logger.globalUsePrint = true;
  
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(600, 800),
      minimumSize: Size(300, 400),
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
    });
  }

  // Initialize Firebase, crash logging, etc.
  await initializeFirebase();
  
  runApp(const Vivant());
}

class Vivant extends StatelessWidget {
  const Vivant({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vivant',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
