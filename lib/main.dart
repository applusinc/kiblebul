import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kiblebul/firebase_options.dart';
import 'package:kiblebul/service.dart';
import 'package:kiblebul/splash_page.dart';
import 'package:permission_handler/permission_handler.dart';

import 'kible_screen.dart';

void main() async {
  //LAST EDITED BY applusinc ON 16.05.2024
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(Platform.isAndroid){
    unawaited(MobileAds.instance.initialize());
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool hasPermission = false;
  bool isLoading = false;

  final _service = FirebaseNotificationService();

  @override
  void initState() {
    super.initState();
    _service.connectNotfication();
    getPermission();
  }

  Future<void> getPermission() async {
    setState(() {
      isLoading = true;
    });

    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      if (status.isGranted) {
        setState(() {
          hasPermission = true;
          isLoading = false;
        });
      } else {
        var result = await requestLocationPermission();
        setState(() {
          hasPermission = result;
          isLoading = false;
        });
      }
    }
  }

  Future<bool> requestLocationPermission() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      if (status.isGranted) {
        return true;
      } else {
        var result = await Permission.location.request();
        return result == PermissionStatus.granted;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        
        colorSchemeSeed: Colors.blue[700],
      ),
      darkTheme: ThemeData.dark().copyWith(),
      themeMode: ThemeMode.dark,
      home: hasPermission ? const SplashPage() : buildPermissionRequestUI(),
    );
  }

  Widget buildPermissionRequestUI() {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 48, 48, 48),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Uygulamayı kullanabilmek için konum servislerin açıp izin vermeniz gerekiyor",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 18),
            ),
            const SizedBox(
              height: 15,
            ),
            isLoading
                ? CircularProgressIndicator()
                : FilledButton(
                    onPressed: getPermission,
                    child: Text("İzin ver"),
                  ),
            TextButton(
              onPressed: redirectToSettings,
              child: Text("Ayarlar"),
            ),
          ],
        ),
      ),
    );
  }

  void redirectToSettings() {
    openAppSettings();
  }
}
