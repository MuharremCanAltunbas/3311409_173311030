import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:waterly/components/MyAppBar.dart';
import 'package:waterly/controllers/AppController.dart';
import 'package:waterly/database/AppDatabase.dart';
import 'package:waterly/extensions/GetMonthName.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:waterly/extensions/LocalNotificationService.dart';
import 'package:waterly/screens/get_premium_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final LocalNotificationService service;

  final AppController controller = Get.find();

  AppDatabase appDatabase = AppDatabase();

  var findReminders = [];

  List<String> hours = [];
  List<String> minutes = [];

  var selectedHour = "1";
  var selectedMinute = "1";

  fillDropdowns() {
    setState(() {
      for (var i = 1; i <= 24; i++) {
        hours.add(i.toString());
      }
      for (var i = 1; i <= 60; i++) {
        minutes.add(i.toString());
      }
    });
  }

  updateReminderList() {
    setState(() {
      findReminders = appDatabase.loadReminders();
    });
  }

  bool userIsPremium = false;
  late CustomerInfo customerInfo;
  Future<void> initPlatformStateForSubscription() async {
    await Purchases.setDebugLogsEnabled(true);
    await Purchases.setup("goog_jYhcXfxjwBFrvfwMCKjvrtpSCRr");
    customerInfo = await Purchases.getCustomerInfo();

    // User premium check
    if (customerInfo.entitlements.all["premium"] != null &&
        customerInfo.entitlements.all["premium"]!.isActive) {
      setState(() {
        userIsPremium = true;
      });
    } else {
      userIsPremium = false;
    }
  }

  @override
  void initState() {
    service = LocalNotificationService();
    service.intialize();
    listenToNotification();
    super.initState();
    initPlatformStateForSubscription();
    fillDropdowns();
    updateReminderList();
  }

  updateNotifications(data) async {
    var id = 0;
    await service.cleanNotifications();

    for (var element in data) {
      id += 1;
      await service.showScheduledNotification(
          id: id,
          title: "Waterly",
          body: element['title'],
          hour: element['hour'],
          minutes: element['minute']);
    }

    print("Update Notifications List");
  }

  removeNotificationFromDb(int hour, int minute) {
    var loadReminders2 = [];
    var loadReminders = appDatabase.loadReminders();
    loadReminders2 = loadReminders;
    print(loadReminders2);
    var removeItem = loadReminders2
        .where(
            (element) => element['hour'] == hour && element['minute'] == minute)
        .first;
    print(removeItem);
    loadReminders2.remove(removeItem);
    appDatabase.updateReminders(loadReminders2);
    updateReminderList();
  }

  void listenToNotification() =>
      service.onNotificationClick.stream.listen(onNoticationListener);

  void onNoticationListener(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      print('payload $payload');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#ffffff"),
      appBar: MyAppBar(appBar: AppBar()),
      body: ListView(
        children: [body(), addButton()],
      ),
    );
  }

  addButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: () {
          if (findReminders.length >= 3 && userIsPremium == false) {
            getPremiumDialog();
          } else {
            addDialog();
          }
        },
        child: Container(
            width: 80,
            decoration: BoxDecoration(
              color: HexColor("#46436a"),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  offset: Offset(0.0, 1.0), //(x,y)
                  blurRadius: 6.0,
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(
                  Icons.add_alarm_outlined,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  "notification_screen_btn_text",
                  style: GoogleFonts.roboto(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ).tr()
              ]),
            )),
      ),
    );
  }

  body() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: findReminders.length > 0
          ? ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemCount: findReminders.length,
              itemBuilder: (context, index) {
                return card(
                    findReminders[index]['title'],
                    findReminders[index]['hour'],
                    findReminders[index]['minute']);
              },
            )
          : nodata(),
    );
  }

  nodata() {
    return Column(
      children: [
        SizedBox(height: 60),
        Icon(
          Icons.notifications_on_rounded,
          size: 60,
          color: Colors.grey.shade800,
        ),
        SizedBox(height: 10),
        Text(
          "notification_screen_error_text",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ).tr(),
        SizedBox(height: 30),
      ],
    );
  }

  card(String title, int hour, int minute) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  removeNotificationFromDb(hour, minute);
                  updateReminderList();
                  updateNotifications(findReminders);
                },
                backgroundColor: Colors.red.shade400,
                icon: Icons.delete,
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: HexColor("#ffffff"),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Icon(Icons.timer),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${hour.toString() + ":" + minute.toString()}",
                            style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: HexColor("#46436a"),
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "notification_screen_title_text",
                            style: GoogleFonts.roboto(
                                fontSize: 13,
                                color: HexColor("#46436a"),
                                fontWeight: FontWeight.w400),
                          ).tr(),
                        ],
                      ),
                    ]),
                    Icon(
                      Icons.arrow_forward_outlined,
                      size: 24,
                      color: HexColor("#46436a"),
                    ),
                  ],
                ),
              ))),
    );
  }

  TimeOfDay timeOfDay = TimeOfDay.now();

  addDialog() async {
    var time = await showTimePicker(context: context, initialTime: timeOfDay);
    if (time != null) {
      findReminders.add({
        "title": "Drinking water reminder",
        "hour": time.hour,
        "minute": time.minute,
      });
      appDatabase.updateReminders(findReminders);
      updateNotifications(findReminders);
      updateReminderList();
    }
    /*
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Time',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  hourminutes()
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                    backgroundColor: HexColor("#46436a"),
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    findReminders.add({
                      "title": "Drinking water reminder",
                      "hour": int.parse(selectedHour),
                      "minute": int.parse(selectedMinute),
                    });
                    appDatabase.updateReminders(findReminders);
                    updateNotifications(findReminders);
                    updateReminderList();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
    */
  }

  getPremiumDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 44,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'premium_notificationheader',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ).tr(),
                  SizedBox(height: 20),
                  Text(
                    'premium_notificationsubheader',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w500, fontSize: 14),
                  ).tr(),
                ],
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'premium_close',
                    style: TextStyle(color: Colors.black),
                  ).tr(),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge,
                    backgroundColor: HexColor("#46436a"),
                  ),
                  child: Text(
                    'premium_getpremium',
                    style: TextStyle(color: Colors.white),
                  ).tr(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => GetPremiumScreen(),
                        transitionDuration: Duration(milliseconds: 300),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  hourminutes() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Text(
                  "Hour",
                  style: GoogleFonts.roboto(
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(right: 0),
                  child: DropdownButtonFormField(
                    value: selectedHour,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedHour = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade600, width: 1),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: hours.length > 0
                        ? hours.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList()
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
            child: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            children: [
              Text(
                "Minute",
                style: GoogleFonts.roboto(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: DropdownButtonFormField(
                  value: selectedMinute,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMinute = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade500, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade600, width: 1),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: minutes.length > 0
                      ? minutes.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList()
                      : null,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
