class BookInfoItemModel {
  const BookInfoItemModel({
    required this.label,
    required this.value,
    this.isStrongValue = false,
  });

  final String label;
  final String value;
  final bool isStrongValue;
}
