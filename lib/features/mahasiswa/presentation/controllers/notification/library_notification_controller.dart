import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/notification/notification_model.dart';

class LibraryNotificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isMarkingAll = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([loadNotifications(), loadUnreadCount()]);
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final service = Get.find<HomeApiService>();
      final result = await service.getNotifications(perPage: 30);
      notifications.assignAll(result.notifications);
    } on LuminaApiException catch (e) {
      errorMessage.value = e.displayMessage;
    } catch (_) {
      errorMessage.value = 'Gagal memuat notifikasi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await Get.find<HomeApiService>().getUnreadNotificationCount();
      unreadCount.value = count;
    } catch (_) {
      // silent fail — badge akan tetap 0
    }
  }

  Future<void> refresh() async {
    await _loadAll();
  }

  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index < 0) return;

    final prev = notifications[index];
    if (prev.isRead) return;

    // Optimistic
    notifications[index] = prev.copyWith(isRead: true, readAt: DateTime.now());
    notifications.refresh();
    if (unreadCount.value > 0) unreadCount.value--;

    try {
      await Get.find<HomeApiService>().markNotificationRead(notificationId);
    } catch (_) {
      // rollback
      notifications[index] = prev;
      notifications.refresh();
      unreadCount.value++;
    }
  }

  Future<void> markAllAsRead() async {
    if (notifications.every((n) => n.isRead)) return;

    isMarkingAll.value = true;
    final prev = notifications.toList();
    final prevCount = unreadCount.value;

    // Optimistic
    final now = DateTime.now();
    notifications.assignAll(
      notifications.map((n) => n.isRead ? n : n.copyWith(isRead: true, readAt: now)).toList(),
    );
    unreadCount.value = 0;

    try {
      await Get.find<HomeApiService>().markAllNotificationsRead();
    } on LuminaApiException catch (_) {
      notifications.assignAll(prev);
      unreadCount.value = prevCount;
    } catch (_) {
      notifications.assignAll(prev);
      unreadCount.value = prevCount;
    } finally {
      isMarkingAll.value = false;
    }
  }

  bool get hasUnread => unreadCount.value > 0;
}
