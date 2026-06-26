import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/mahasiswa/presentation/controllers/notification/library_notification_controller.dart';
import 'package:lumina_library/shared/models/notification/notification_model.dart';
import 'package:lumina_library/shared/widgets/skeleton/lumina_skeleton.dart';

class LibraryNotificationPage extends StatelessWidget {
  const LibraryNotificationPage({super.key});

  LibraryNotificationController get controller =>
      Get.isRegistered<LibraryNotificationController>()
          ? Get.find<LibraryNotificationController>()
          : Get.put(LibraryNotificationController());

  @override
  Widget build(BuildContext context) {
    final ctrl = controller;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: Column(
        children: [
          // ── Top bar ──────────────────────────────────────────────────────
          Obx(() => _NotificationTopBar(
                hasUnread: ctrl.hasUnread,
                isMarkingAll: ctrl.isMarkingAll.value,
                onBackTap: Get.back,
                onMarkAllTap: ctrl.markAllAsRead,
              )),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const _NotificationSkeletonList();
              }

              if (ctrl.errorMessage.value.isNotEmpty &&
                  ctrl.notifications.isEmpty) {
                return _ErrorState(
                  message: ctrl.errorMessage.value,
                  onRetry: ctrl.loadNotifications,
                );
              }

              if (ctrl.notifications.isEmpty) {
                return const _EmptyState();
              }

              return RefreshIndicator(
                color: LuminaColors.secondary,
                backgroundColor: LuminaColors.surfaceContainerLowest,
                onRefresh: ctrl.refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.sm),
                  itemCount: ctrl.notifications.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    thickness: 1,
                    color: LuminaColors.outlineVariant.withOpacity(0.15),
                    indent: LuminaSpacing.marginMobile,
                    endIndent: LuminaSpacing.marginMobile,
                  ),
                  itemBuilder: (context, index) {
                    final notif = ctrl.notifications[index];
                    return _NotificationTile(
                      notification: notif,
                      onTap: () => ctrl.markAsRead(notif.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────

class _NotificationTopBar extends StatelessWidget {
  const _NotificationTopBar({
    required this.hasUnread,
    required this.isMarkingAll,
    required this.onBackTap,
    required this.onMarkAllTap,
  });

  final bool hasUnread;
  final bool isMarkingAll;
  final VoidCallback onBackTap;
  final VoidCallback onMarkAllTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LuminaColors.surface,
      elevation: 0,
      child: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: LuminaColors.outlineVariant.withOpacity(0.25),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: LuminaSpacing.marginMobile,
            vertical: LuminaSpacing.sm,
          ),
          child: Row(
            children: [
              _IconBtn(icon: Icons.arrow_back_rounded, onTap: onBackTap),
              const SizedBox(width: LuminaSpacing.sm),
              Expanded(
                child: Text(
                  'Notifikasi',
                  style: LuminaTextStyles.headlineSm.copyWith(
                    color: LuminaColors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              if (hasUnread)
                isMarkingAll
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: LuminaColors.secondary,
                        ),
                      )
                    : TextButton(
                        onPressed: onMarkAllTap,
                        style: TextButton.styleFrom(
                          foregroundColor: LuminaColors.secondary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: Text(
                          'Tandai semua dibaca',
                          style: LuminaTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, color: LuminaColors.onSurfaceVariant, size: 24),
        ),
      ),
    );
  }
}

// ─── Notification tile ────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LuminaSpacing.marginMobile,
          vertical: LuminaSpacing.md,
        ),
        color: isUnread
            ? LuminaColors.primary.withOpacity(0.04)
            : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnread
                    ? LuminaColors.primary.withOpacity(0.10)
                    : LuminaColors.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconForType(notification.type),
                color: isUnread ? LuminaColors.primary : LuminaColors.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: LuminaSpacing.sm),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: LuminaTextStyles.titleSm.copyWith(
                            color: LuminaColors.onSurface,
                            fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: LuminaColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LuminaTextStyles.bodyMd.copyWith(
                      color: LuminaColors.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: LuminaSpacing.xs),
                  Text(
                    _formatDate(notification.createdAt),
                    style: LuminaTextStyles.labelMd.copyWith(
                      color: LuminaColors.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'borrow':
      case 'borrowing':
        return Icons.import_contacts_rounded;
      case 'return':
        return Icons.assignment_return_rounded;
      case 'fine':
        return Icons.account_balance_wallet_rounded;
      case 'reminder':
        return Icons.access_time_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';

    return DateFormat('d MMM yyyy', 'id').format(dt);
  }
}

// ─── Skeleton ─────────────────────────────────────────────────────────────────

class _NotificationSkeletonList extends StatelessWidget {
  const _NotificationSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: LuminaSpacing.sm),
      itemCount: 8,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 1,
        color: LuminaColors.outlineVariant.withOpacity(0.15),
        indent: LuminaSpacing.marginMobile,
        endIndent: LuminaSpacing.marginMobile,
      ),
      itemBuilder: (_, _) => const _NotificationTileSkeleton(),
    );
  }
}

class _NotificationTileSkeleton extends StatelessWidget {
  const _NotificationTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LuminaSpacing.marginMobile,
        vertical: LuminaSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LuminaSkeleton(
            width: 44,
            height: 44,
            radius: LuminaRadius.full,
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                LuminaSkeleton(width: 160, height: 14, radius: LuminaRadius.sm),
                SizedBox(height: 8),
                LuminaSkeleton(width: double.infinity, height: 12, radius: LuminaRadius.sm),
                SizedBox(height: 4),
                LuminaSkeleton(width: 200, height: 12, radius: LuminaRadius.sm),
                SizedBox(height: 8),
                LuminaSkeleton(width: 80, height: 11, radius: LuminaRadius.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLowest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: LuminaColors.primary.withOpacity(0.7),
                size: 52,
              ),
            ),
            const SizedBox(height: LuminaSpacing.xl),
            Text(
              'Belum Ada Notifikasi',
              style: LuminaTextStyles.titleLg.copyWith(
                color: LuminaColors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: LuminaSpacing.sm),
            Text(
              'Notifikasi peminjaman, pengembalian, dan pengingat\nakan muncul di sini.',
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(
                color: LuminaColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(LuminaSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: LuminaColors.onSurfaceVariant, size: 48),
            const SizedBox(height: LuminaSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant),
            ),
            const SizedBox(height: LuminaSpacing.lg),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: LuminaColors.primary,
                foregroundColor: LuminaColors.onPrimary,
                elevation: 0,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
