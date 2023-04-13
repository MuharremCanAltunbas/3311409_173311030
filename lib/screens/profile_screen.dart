import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:waterly/components/MyAppBar.dart';
import 'package:waterly/database/AppDatabase.dart';
import 'package:waterly/extensions/HexColor.dart';
import 'package:waterly/screens/home_screen.dart';
import 'package:waterly/screens/notification_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  AppDatabase appDatabase = AppDatabase();

  final _formKey = GlobalKey<FormState>();
  TextEditingController txtName = TextEditingController();

  var user = {};

  String selectedGender = "Male";
  String selectedHeight = "170 cm";
  String selectedWeight = "65 kg";
  String selectedNeedWater = "2.3";
  String selectedCountry = "en_US";

  List<String> heights = [];
  List<String> weights = [];

  changeGender() {
    setState(() {
      selectedGender = selectedGender == 'Male' ? 'Female' : 'Male';
    });
  }

  fillDropdowns() {
    setState(() {
      for (var i = 100; i <= 230; i++) {
        heights.add(i.toString() + " cm");
      }
      for (var i = 30; i <= 200; i++) {
        weights.add(i.toString() + " kg");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fillDropdowns();
    setState(() {
      user = appDatabase.loadUser();
      print(user);
      txtName.text = user['name'];
      selectedHeight = user['height'];
      selectedWeight = user['weight'];
      selectedNeedWater = user['needwater'];
      selectedGender = user['gender'];
      selectedCountry = user['country'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#ffffff"),
      appBar: MyAppBar(
        appBar: AppBar(),
      ),
      body: profileScreen(),
    );
  }

  profileScreen() {
    return Padding(
      padding: EdgeInsets.all(30),
      child: ListView(
        children: [
          myForm(),
          SizedBox(height: 40),
          notificationSettingsTitle(),
          SizedBox(height: 20),
          notificationSettingsPage(),
          SizedBox(height: 40),
          appLanguageTitle(),
          SizedBox(height: 20),
          appLanguageChange(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  myForm() {
    return Column(
      children: [
        Text(
          "splash_screen4_title".tr(),
          style:
              GoogleFonts.roboto(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Form(
            key: _formKey,
            child: TextFormField(
              controller: txtName,
              decoration: InputDecoration(
                hintText: tr('splash_screen4_entername'),
                labelText: tr('splash_screen4_name'),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade500,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return tr('splash_screen4_nameerror');
                }
              },
            )),
        SizedBox(height: 40),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedGender = 'Male';
                  });
                },
                child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: selectedGender == 'Male'
                          ? HexColor("#46436a")
                          : Colors.white,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male_outlined,
                            color: selectedGender == 'Male'
                                ? Colors.white
                                : HexColor("#46436a"),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "splash_screen4_male".tr(),
                            style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: selectedGender == 'Male'
                                    ? Colors.white
                                    : HexColor("#46436a"),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedGender = 'Female';
                  });
                },
                child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: selectedGender == 'Female'
                          ? HexColor("#46436a")
                          : Colors.white,
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female_outlined,
                            color: selectedGender == 'Female'
                                ? Colors.white
                                : HexColor("#46436a"),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "splash_screen4_female".tr(),
                            style: GoogleFonts.roboto(
                                fontSize: 16,
                                color: selectedGender == 'Female'
                                    ? Colors.white
                                    : HexColor("#46436a"),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
              )
            ],
          ),
        ),
        SizedBox(height: 20),
        heightweight(),
        SizedBox(height: 25),
        updateDailyNeedWater(),
        SizedBox(height: 25),
        saveButton(),
      ],
    );
  }

  heightweight() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Text(
                  "splash_screen4_height".tr(),
                  style: GoogleFonts.roboto(
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(right: 0),
                  child: DropdownButtonFormField(
                    value: selectedHeight,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedHeight = newValue!;
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
                    items: heights.length > 0
                        ? heights.map<DropdownMenuItem<String>>((String value) {
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
                "splash_screen4_weight".tr(),
                style: GoogleFonts.roboto(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: DropdownButtonFormField(
                  value: selectedWeight,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedWeight = newValue!;
                      num weight = double.parse(newValue.split(' ')[0]);
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
                  items: weights.length > 0
                      ? weights.map<DropdownMenuItem<String>>((String value) {
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

  updateDailyNeedWater() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
            onTap: () {
              setState(() {
                selectedNeedWater =
                    (double.parse(selectedNeedWater) - 0.1).toStringAsFixed(1);
              });
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
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
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Center(
                    child: Icon(Icons.arrow_downward_outlined),
                  )),
            )),
        Column(
          children: [
            Text(
              "profile_screen_dailywaterneeds".tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: Colors.black,
                  fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 4),
            Text(
              "$selectedNeedWater",
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                  fontSize: 21,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        GestureDetector(
            onTap: () {
              setState(() {
                selectedNeedWater =
                    (double.parse(selectedNeedWater) + 0.1).toStringAsFixed(1);
              });
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
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
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Center(
                    child: Icon(Icons.arrow_upward_outlined),
                  )),
            )),
      ],
    );
  }

  saveButton() {
    return GestureDetector(
      onTap: () {
        if (_formKey.currentState!.validate()) {
          var user1 = {
            "name": txtName.text,
            "height": selectedHeight,
            "weight": selectedWeight,
            "gender": selectedGender,
            "needwater": selectedNeedWater,
            "country": user['country'],
          };

          print(user1);
          appDatabase.updateUser(user1);

          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
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
            child: Center(
                child: Text(
              "profile_screen_save_btn",
              style: GoogleFonts.roboto(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ).tr()),
          )),
    );
  }

  appLanguageTitle() {
    return Text(
      "profile_screen_changeapplanguage".tr(),
      textAlign: TextAlign.left,
      style: GoogleFonts.roboto(
          fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  appLanguageChange() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appLanguageCard("English", "england.png", "en_US"),
              appLanguageCard("German", "germany.png", "de_DE"),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appLanguageCard("Spanish", "spain.png", "es_ES"),
              appLanguageCard("French", "france.jpg", "fr_FR"),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appLanguageCard("Italian", "italy.png", "it_IT"),
              appLanguageCard("Turkish", "turkey.jpeg", "tr_TR"),
            ],
          )
        ],
      ),
    );
  }

  appLanguageCard(String title, String flag, String code) {
    return GestureDetector(
      onTap: () {
        context.setLocale(Locale(code.split("_")[0], code.split("_")[1]));
        setState(() {
          selectedCountry = code;
          var user1 = {
            "name": user["name"],
            "height": user["height"],
            "weight": user["weight"],
            "gender": user["gender"],
            "needwater": user["needwater"],
            "country": code,
          };
          appDatabase.updateUser(user1);
        });
      },
      child: Container(
          width: 150,
          decoration: BoxDecoration(
            color: selectedCountry == code ? HexColor("#46436a") : Colors.white,
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
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image(
                    width: 40,
                    height: 30,
                    fit: BoxFit.cover,
                    image: AssetImage("assets/flags/" + flag)),
                SizedBox(width: 15),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: selectedCountry == code
                          ? Colors.white
                          : HexColor("#46436a"),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )),
    );
  }

  notificationSettingsTitle() {
    return Text(
      "profile_screen_notificationsettings".tr(),
      textAlign: TextAlign.left,
      style: GoogleFonts.roboto(
          fontSize: 21, color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  notificationSettingsPage() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NotificationScreen()),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Container(
            width: MediaQuery.of(context).size.width,
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
              child: Center(
                  child: Text(
                "profile_screen_viewnotificationsettings".tr(),
                style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              )),
            )),
      ),
    );
  }
}
