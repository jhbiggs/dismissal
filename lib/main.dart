import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    /// This HttpOverride will be set globally in the app.
  // HttpOverrides.global = MyHttpOverrides();
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port){
      // Allowing only our Base API URL.
      List<String> validHosts = ["http://localhost:443", 
      "https://localhost:443", "http://ec2-52-201-69-55.compute-1.amazonaws.com:443", 
      "https://ec2-52-201-69-55.compute-1.amazonaws.com:443", "http://localhost:80",
      "https://localhost:80", "http://ec2-52-201-69-55.compute-1.amazonaws.com:80",
      "ws://localhost:80", "ws://ec2-52-201-69-55.compute-1.amazonaws.com:80",];
      
      final isValidHost = validHosts.contains(host);
      return isValidHost;
      
      // return true if you want to allow all host. (This isn't recommended.)
      // return true;
    };
  }
}