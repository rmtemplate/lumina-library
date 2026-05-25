import 'package:get/get.dart';

class StaffHomeController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  void changeIndex(int index) {
    if (selectedIndex.value == index) return;
    selectedIndex.value = index;
  }
}
