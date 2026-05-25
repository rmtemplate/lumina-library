import 'package:get/get.dart';

class LibraryLocationDetailController extends GetxController {
  final RxBool isFavorite = false.obs;

  void toggleFavorite() {
    isFavorite.toggle();
  }
}
