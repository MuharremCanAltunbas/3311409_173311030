import 'package:hive_flutter/hive_flutter.dart';

final _myBox = Hive.box("myBox");
// veri yükleyip silmek için
class AppDatabase {
  List<dynamic> loadData(DateTime datetime) {
    String key = datetime.day.toString() +
        "-" +
        datetime.month.toString() +
        "-" +
        datetime.year.toString();
    try {
      return _myBox.get(key);
    } catch (e) {
      return [];
    }
  }

  void removeData(DateTime datetime) {
    String key = datetime.day.toString() +
        "-" +
        datetime.month.toString() +
        "-" +
        datetime.year.toString();

    var findData = [];
    var data = _myBox.get(key);
    findData = data;
    var removeData =
        findData.where((element) => element["date"] == datetime).first;
    print(removeData);
    findData.remove(removeData);
    updateDatabase(datetime, findData);
  }

  void updateDatabase(DateTime datetime, List<dynamic> data) {
    String key = datetime.day.toString() +
        "-" +
        datetime.month.toString() +
        "-" +
        datetime.year.toString();

    _myBox.put(key, data);
  }

  loadUser() {
    String key = "user";
    try {
      return _myBox.get(key);
    } catch (e) {
      return null;
    }
  }

  void updateUser(data) {
    String key = "user";
    _myBox.put(key, data);
  }

  loadGetPremium() {
    String key = "isPremium";
    try {
      return _myBox.get(key);
    } catch (e) {
      return null;
    }
  }

  void updateGetPremium(bool state) {
    String key = "isPremium";
    _myBox.put(key, state);
  }

  List<dynamic> loadReminders() {
    String key = "reminders";
    try {
      return _myBox.get(key);
    } catch (e) {
      return [];
    }
  }

  void updateReminders(List<dynamic> data) {
    String key = "reminders";
    _myBox.put(key, data);
  }

  List<dynamic> getWeekData() {
    var list = [];
    DateTime datetime = DateTime.now();
    for (var i = (7 - datetime.weekday); i >= 1; i--) {
      list.add([]);
    }
    for (var i = 0; i < datetime.weekday; i++) {
      var findDate = datetime.subtract(Duration(days: i));
      String key = findDate.day.toString() +
          "-" +
          findDate.month.toString() +
          "-" +
          findDate.year.toString();
      try {
        var data = _myBox.get(key);
        if (data != null) {
          list.add(data);
        } else {
          list.add([]);
        }
      } catch (e) {
        print(key + " tarihinde yok");
      }
    }
    return list;
  }

  List<dynamic> getMonthData() {
    var list = [];
    DateTime datetime = DateTime.now();
    for (var i = 1; i <= 31; i++) {
      String key = i.toString() +
          "-" +
          datetime.month.toString() +
          "-" +
          datetime.year.toString();
      try {
        var data = _myBox.get(key);
        if (data != null) {
          var sum = 0.0;
          for (var element in data) {
            sum += element['value'];
          }
          list.add(sum / 1000);
        } else {
          list.add(0);
        }
      } catch (e) {
        print(key + " tarihinde yok");
      }
    }
    return list;
  }

  List<dynamic> getYearData() {
    var result = [];
    // 12 ay icin ortalamalar donulecek
    DateTime datetime = DateTime.now();
    for (var ay = 1; ay <= 12; ay++) {
      var list = [];
      var total = 0.0;
      var average = 0.0;
      for (var gun = 1; gun < 31; gun++) {
        String key = gun.toString() +
            "-" +
            ay.toString() +
            "-" +
            datetime.year.toString();

        try {
          var data = _myBox.get(key);
          if (data != null) {
            for (var element in data) {
              total += element['value'];
            }
          }
        } catch (e) {
          print(key + " tarihinde yok");
        }
      }
      average =
          (total / DateTime(datetime.year, datetime.month + 1, 0).day) / 1000;
      result.add(average);
    }
    return result;
  }
}
