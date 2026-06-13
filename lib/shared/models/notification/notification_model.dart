/// Model notifikasi dari backend.
/// Response format: { id, type, title, body, reference_type, reference_id, is_read, read_at, created_at }
class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.type,
    this.referenceType,
    this.referenceId,
    this.readAt,
  });

  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final String? type;
  final String? referenceType;
  final String? referenceId;
  final DateTime? readAt;

  NotificationModel copyWith({bool? isRead, DateTime? readAt}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      type: type,
      referenceType: referenceType,
      referenceId: referenceId,
      readAt: readAt ?? this.readAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isRead: json['is_read'] == true,
      type: json['type']?.toString(),
      referenceType: json['reference_type']?.toString(),
      referenceId: json['reference_id']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      readAt: json['read_at'] != null
          ? DateTime.tryParse(json['read_at'].toString())
          : null,
    );
  }
}

class NotificationListResult {
  const NotificationListResult({
    required this.notifications,
    required this.total,
    required this.currentPage,
    required this.lastPage,
  });

  final List<NotificationModel> notifications;
  final int total;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;

  factory NotificationListResult.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return NotificationListResult(
      notifications: rawData
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (meta['total'] as num?)?.toInt() ?? rawData.length,
      currentPage: (meta['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (meta['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}
