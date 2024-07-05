import 'package:flutter/material.dart';

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:testfireapi/api/firebase_api.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:starsview/config/StarsConfig.dart';
import 'package:starsview/starsview.dart';
import 'package:starsview/config/MeteoriteConfig.dart';
import 'package:simple_shadow/simple_shadow.dart';
import 'package:wear/wear.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
              apiKey: 'AIzaSyBSqIVScNz7CPAhk4Ta-lEmDeH4gR_woDo',
              appId: '1:14477277224:android:3952694b735054cd4bdd1d',
              messagingSenderId: '14477277224',
              projectId: 'wear-7484f'))
      : await Firebase.initializeApp();

  FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      title: 'LED Controller',
      themeMode: ThemeMode.dark,
      theme: NeumorphicThemeData(
        baseColor: Color(0xFFFFFFFF),
        lightSource: LightSource.topLeft,
        depth: 10,
      ),
      darkTheme: NeumorphicThemeData(
        baseColor: Color(0xFF09061A),
        lightSource: LightSource.topLeft,
        shadowLightColor: Color.fromARGB(255, 19, 13, 53),
        shadowDarkColor: Color.fromARGB(255, 2, 2, 7),
        depth: 8,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double intensity = 1.0;
  bool isOn = true;
  late StreamSubscription<void> _notificationSubscription;
  String? mensaje;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _notificationSubscription = FirebaseApi.notificationStream.listen((_) {
      mensaje = FirebaseApi.mensaje;
      setState(() {
        if (mensaje != null) {
          if (mensaje == "El LED se ha apagado") {
            isOn = false;
          } else {
            isOn = true;
          }
        } else {
          isOn = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return Stack(
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color.fromARGB(255, 5, 4, 16),
                        Color.fromARGB(255, 6, 4, 19),
                        Color.fromARGB(255, 9, 6, 26),
                        Color.fromARGB(255, 18, 12, 52),
                      ],
                    ),
                  ),
                ),
                StarsView(
                  fps: 60,
                  starsConfig: mode == WearMode.active
                      ? StarsConfig(minStarSize: 0, maxStarSize: 2)
                      : StarsConfig(starCount: 0),
                  meteoriteConfig: MeteoriteConfig(enabled: true),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      isOn
                          ? SimpleShadow(
                              sigma: 19,
                              color: Color.fromARGB(255, 255, 214, 0),
                              opacity: 1,
                              offset: Offset(0, 0),
                              child: Image.asset(
                                "assets/images/foco.png",
                                height: 100,
                                color: Color.fromARGB(255, 255, 214, 0),
                              ),
                            )
                          : Image.asset(
                              "assets/images/foco.png",
                              height: 100,
                            ),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }
}
