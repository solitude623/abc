import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isss/amap/location.dart';
import 'package:isss/common/settings.dart';
import 'package:isss/common/utils/common_sp.dart';
import 'package:isss/common/utils/deviceInfoUtils.dart';
import 'package:isss/common/utils/fileUtils.dart';
import 'package:isss/developer/proxyManager.dart';
import 'package:isss/homepage/view/homePage.dart';
import 'package:isss/login/loginPage.dart';
import 'package:isss/common/res/strings.dart';
import 'package:isss/network/network.dart';
import 'package:isss/notification/remind_manager.dart';
import 'package:isss/repository/model/account.dart';
import 'package:isss/repository/model/repository.dart';
import 'package:isss/common/utils/sentryUtil.dart';

Future<Null> main() async {
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };

  runZoned<Future<Null>>(() async {
    runApp(APPSharedData(child: ISSSApp()));
  }, onError: (error, stackTrace) async {
    await reportError(error, stackTrace);
  });
}

class ISSSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.APP_NAME,
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: SplashPage(),
      navigatorObservers: [APPSharedData.of(context).navigatorObserver],
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    _initApp().then((_) {
      if (AccountModel.instance().isLogin()) {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => HomePage(),
        ));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (_) => LoginPage(),
        ));
      }
    });
    return Container();
  }

  Future<bool> _initApp() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
      return DeviceInfoUtil().init();
    }).then((_) {
      return FileUtils.init();
    }).then((_) {
      return AccountModel.init();
    }).then((_) {
      return ProxyManager.init();
    }).then((_) {
      return Network.init();
    }).then((_) {
      return CommonSharedPreference.init();
    }).then((_) {
      return LocationHelper().init();
    }).then((_) {
      Settings.init();
      RemindManager.init();
      AnswerRepository();
      Repository();
    }).catchError((error, stackTrace) {
      reportError(error, stackTrace);
    });
    return true;
  }
}

class APPSharedData extends InheritedWidget {

  APPSharedData({ Key key, Widget child }) : super(key: key, child: child);

  static APPSharedData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<APPSharedData>();
  }

  final RouteObserver navigatorObserver = RouteObserver<ModalRoute>();

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
