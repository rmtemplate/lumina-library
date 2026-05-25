import 'cart_book_model.dart';

class CartLibraryGroupModel {
  CartLibraryGroupModel({
    required this.libraryId,
    required this.libraryName,
    required this.items,
  });

  final String libraryId;
  final String libraryName;
  final List<LibraryCartBook> items;
}
