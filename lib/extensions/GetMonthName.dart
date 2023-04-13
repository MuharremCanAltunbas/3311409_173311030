import 'package:easy_localization/easy_localization.dart';

class GetMonthName {
  String find(int index) {
    if (index == 1) {
      return tr('january');
    } else if (index == 2) {
      return tr('february');
    } else if (index == 3) {
      return tr('march');
    } else if (index == 4) {
      return tr('april');
    } else if (index == 5) {
      return tr('may');
    } else if (index == 6) {
      return tr('june');
    } else if (index == 7) {
      return tr('july');
    } else if (index == 8) {
      return tr('august');
    } else if (index == 9) {
      return tr('september');
    } else if (index == 10) {
      return tr('october');
    } else if (index == 11) {
      return tr('november');
    } else if (index == 12) {
      return tr('december');
    } else {
      return tr('january');
    }
  }
}
