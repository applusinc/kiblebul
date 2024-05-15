import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kiblebul/kible_screen.dart';
import 'package:kiblebul/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  get adSize => null;

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String privacy = "";
  ValueNotifier<int> isAccepted = ValueNotifier(0);
  late ConfettiController _confettiController;
  bool buttonEnabled = true;
  
  //waiting = 0
  //accepted = 1
  //rejected = 2
  

  @override
  void initState() {
    _confettiController = ConfettiController(duration: Duration(seconds: 1));
    SharedPreferences.getInstance().then((pref) {
      if (pref.getBool("policy") ?? false) {
        isAccepted.value = 1;
        Future.delayed(Duration(seconds: 3)).then((value) {
          Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => QiblahScreen(),
              ));
        });
      } else {
        isAccepted.value = 2;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isAccepted,
      builder: (context, value, child) {
        if (value == 0) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/splash.png",
                    color: Colors.white,
                    scale: 3,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  CircularProgressIndicator()
                ],
              ),
            ),
          );
        } else {
          if (value == 1) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/splash.png",
                      color: Colors.white,
                      scale: 3,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CircularProgressIndicator()
                  ],
                ),
              ),
            );
          } else {
            return Scaffold(
              body: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ConfettiWidget(
                    blastDirection: pi,
                    emissionFrequency: 0.2,
                    numberOfParticles: 10,
                    blastDirectionality: BlastDirectionality.explosive,
                    gravity: 0.1,
                    confettiController: _confettiController,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Uygulamaya devam ederek hizmet şartlarımızı kabul etmiş olursunuz.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Gizlilik Politikası'),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  scrollable: true,
                                  content: Text(Utils.policy),
                                  actionsAlignment: MainAxisAlignment.center,
                                  actions: [
                                    OutlinedButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Tamam'),
                                    )
                                  ],
                                ),
                              ),
                              child: Text(
                                "Gizlilik Sözleşmemiz",
                                style: GoogleFonts.montserrat(
                                    fontSize: 16, color: Colors.purple),
                              ),
                            ),
                            Text(
                              "'i gör.",
                              style: GoogleFonts.montserrat(fontSize: 16),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        FilledButton(
                            style: ButtonStyle(
                                backgroundColor: buttonEnabled
                                    ? null
                                    : MaterialStateProperty.all<Color>(
                                        Colors.grey)),
                            onPressed: () async {
                              if (buttonEnabled) {
                                setState(() {
                                  buttonEnabled = false;
                                });
                                _confettiController.play();
                                SharedPreferences pref =
                                    await SharedPreferences.getInstance();
                                pref.setBool("policy", true);
                                Future.delayed(Duration(seconds: 5))
                                    .then((value) => Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => QiblahScreen(),
                                        )));
                              }
                            },
                            child: Text("Devam et")),
                      ],
                    ),
                  ),
                  Text("")
                ],
              ),
            );
          }
        }
      },
    );
  }
}
