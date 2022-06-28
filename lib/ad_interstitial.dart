import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyAdInterstitial {
  InterstitialAd? _interstitialAd;
  int _loadFailCount = 0;

  /// create interstitial ads
  void createAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // 広告が正常にロードされたときに呼ばれます。
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('### ad loaded');
          _interstitialAd = ad;
          _loadFailCount = 0;
        },
        // 広告のロードが失敗した際に呼ばれます。
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('### ad load failed $error');
          _loadFailCount++;
          _interstitialAd = null;
          if (_loadFailCount <= 2) {
            createAd();
          }
        },
      ),
    );
  }

  /// show interstitial ads to user
  Future<void> showAd() async {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint("### ad onAdShowedFullscreen");
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint("### ad Disposed");
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('### $ad OnAdFailed $error');
        ad.dispose();
        createAd();
      },
    );

    // 広告の表示には.show()を使う
    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  // 広告IDをプラットフォームに合わせて取得
  static String get interstitialAdUnitId {
    var isRelease = const bool.fromEnvironment('dart.vm.product');
    if (!isRelease) {
      // debug実行時
      return 'ca-app-pub-3940256099942544/1033173712'; // test id
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-7901110613766890/8564729963'; // my id
    } else {
      return 'ca-app-pub-3940256099942544/2934735716'; // test id
    }
  }
}
