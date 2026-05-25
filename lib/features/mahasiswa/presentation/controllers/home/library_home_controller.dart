import 'package:get/get.dart';

class LibraryHomeController extends GetxController {
  final RxInt selectedNavIndex = 0.obs;

  void changeNavIndex(int index) {
    if (selectedNavIndex.value == index) return;
    selectedNavIndex.value = index;
  }
}
