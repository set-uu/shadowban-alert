import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class MyAdBanner {
  static BannerAd? _banner;

  static BannerAd createBanner() {
    return _banner ??= BannerAd(
      size: AdSize.banner,
      adUnitId: bannerAdUnitId,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner $ad failed to load: $error');
          _banner?.dispose();
        },
      ),
      request: const AdRequest(),
    )
      ..load();
  }

  static String get bannerAdUnitId {
    if (kDebugMode) {
      // debug実行時
      debugPrint('### ad unit id TEST');
      return 'ca-app-pub-3940256099942544/6300978111'; // test id
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-7901110613766890/1441663272'; // my id
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // test id
    }
  }
}