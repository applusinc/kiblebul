import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kiblebul/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

Animation<double>? animation;
AnimationController? _animationController;
double begin = 0.0;
ValueNotifier<bool> isRotated = ValueNotifier<bool>(false);

class _QiblahScreenState extends State<QiblahScreen>
    with TickerProviderStateMixin {
  late Animation<Color?> _colorAnimation;
  late AnimationController _colorAnimationController;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool vibrated = false;

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: Utils.intID,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {},
          );

          setState(() {
            _interstitialAd = ad;
          });
          _interstitialAd!.show();
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: Utils.bannerID,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);

    _colorAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _colorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 48, 48, 48),
      end: Colors.green,
    ).animate(_colorAnimationController);
    if(Platform.isAndroid){
      _loadInterstitialAd();
    _loadAd();
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _colorAnimationController.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
          valueListenable: isRotated,
          builder: (context, value, child) {
            if (value) {
              _colorAnimationController.forward();
              if (!vibrated) {
                Vibration.vibrate();
                vibrated = true;
              }
            } else {
              _colorAnimationController.reverse();
              vibrated = false;
            }

            return AnimatedBuilder(
              animation: _colorAnimation,
              builder: (context, child) {
                SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                  statusBarColor: _colorAnimation.value,
                ));

                return Scaffold(
                  appBar: AppBar(
                    title: Text(
                      "Kıble Pusulası",
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        color: Colors.white,
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Kalibre Et'),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                scrollable: true,
                                content: Column(
                                  children: [
                                    Text(
                                        '''Yüksek doğruluk için kıbleyi kalibre etmeniz gerekebilir.\nTelefonunuzu elinizde düz tutun ve birkaç kez sekiz şekli hareketiyle hareket ettirin. Bu hareket, telefonun sensörlerinin Dünya'nın manyetik alanını farklı açılardan algılamasına yardımcı olur.
Olası tüm yönleri kapsayacak şekilde telefonunuzu üç eksenin (yuvarlanma, eğim ve yalpalama) etrafında döndürün.
Pusula uygulaması tutarlı ve doğru ölçümler gösterene kadar telefonu döndürürken sekiz rakamı hareketini birkaç kez tekrarlayın.''', textAlign: TextAlign.start,),
                                  Image.asset("assets/images/compass-calibration.png", scale: 1,)
                                  ],
                                ),
                                actions: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Tamam'),
                                  ),
                                  
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.help_outline_rounded,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ],
                    centerTitle: true,
                    backgroundColor: _colorAnimation.value,
                  ),
                  body: Container(
                    color: _colorAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.white70, width: 1),
                                  borderRadius: BorderRadius.circular(32)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Image.asset(
                                    "assets/images/kabe.png",
                                    color: Colors.white,
                                    height: 50,
                                  ),
                                  StreamBuilder(
                                    stream: FlutterQiblah.qiblahStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                            alignment: Alignment.center,
                                            child:
                                                const CircularProgressIndicator(
                                              color: Colors.white,
                                            ));
                                      }

                                      final qiblahDirection = snapshot.data;

                                      // Güncellemeyi build aşamasının dışında yapıyoruz
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        double difference =
                                            (qiblahDirection!.offset -
                                                    qiblahDirection.direction)
                                                .abs();

                                        if (difference < 5) {
                                          isRotated.value = true;
                                        } else {
                                          isRotated.value = false;
                                        }
                                      });

                                      animation = Tween(
                                              begin: begin,
                                              end: (qiblahDirection!.qiblah *
                                                  (pi / 180) *
                                                  -1))
                                          .animate(_animationController!);
                                      begin = (qiblahDirection.qiblah *
                                          (pi / 180) *
                                          -1);
                                      _animationController!.forward(from: 0);

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                "Kabe açısı: ",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20),
                                              ),
                                              Text(
                                                "${qiblahDirection.offset.toInt()}°",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                              height: 325,
                                              child: AnimatedBuilder(
                                                animation: animation!,
                                                builder: (context, child) =>
                                                    Transform.rotate(
                                                        angle: animation!.value,
                                                        child: Image.asset(
                                                          'assets/images/qibla.png',
                                                        )),
                                              )),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text("Açınız: ",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22)),
                                              Text(
                                                  "${qiblahDirection.direction.toStringAsFixed(1)}°",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: AdSize.banner.width.toDouble(),
                            height: AdSize.banner.height.toDouble(),
                            child: _bannerAd == null
                                // Nothing to render yet.
                                ? SizedBox()
                                // The actual ad.
                                : AdWidget(ad: _bannerAd!),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
    );
  }

  Future<void> openUrl(String url) async {
    final _url = Uri.parse(url);
    if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
      // <--
      debugPrint("error in openUrl");
    }
  }
}
