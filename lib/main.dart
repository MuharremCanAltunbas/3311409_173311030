import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:waterly/controllers/AppController.dart';
import 'package:waterly/database/AppDatabase.dart';
import 'package:waterly/extensions/LocalNotificationService.dart';
import 'package:waterly/screens/get_premium_screen.dart';
import 'package:waterly/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:waterly/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox("myBox");
  runApp(
    EasyLocalization(
        supportedLocales: [
          Locale('en', 'US'),
          Locale('tr', 'TR'),
          Locale('de', 'DE'),
          Locale('es', 'ES'),
          Locale('fr', 'FR'),
          Locale('it', 'IT')
        ],
        path: 'assets/translations',
        fallbackLocale: Locale('en', 'US'),
        child: MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppController controller = Get.put(AppController());

  AppDatabase appDatabase = AppDatabase();

  var selectedTheme = "";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waterly',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        accentColor: Colors.white,
      ),
      home: LayoutScreen(),
    );
  }
}

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  AppDatabase appDatabase = AppDatabase();

  var user;
  var isPremium;

  getUserInfo() {
    setState(() {
      user = appDatabase.loadUser();
      if (user == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => SplashScreen()),
              (Route<dynamic> route) => false);
        });
      } else {
        print("user null degil");
        print(user);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (Route<dynamic> route) => false);
        });

        /*
        isPremium = appDatabase.loadGetPremium();

        if (isPremium == null) {
          appDatabase.updateGetPremium(false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => GetPremiumScreen()),
                (Route<dynamic> route) => false);
          });
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false);
          });
        }
        */
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("")),
    );
  }
}
