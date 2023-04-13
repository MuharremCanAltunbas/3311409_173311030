import 'package:flutter/material.dart';
import 'package:get/get.dart';


// State yönetimi data güncelleme
class AppController extends GetxController {
  var count = 0.obs;
  updateData() {
    count.value++;
    update();
  }
}
