enum BorrowedBookStatus {
  active,
  dueSoon,
  overdue,
  finished,
}

class BorrowedBookModel {
  const BorrowedBookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.dueDateLabel,
    required this.progress,
    required this.status,
  });

  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final String dueDateLabel;
  final double progress;
  final BorrowedBookStatus status;
}
