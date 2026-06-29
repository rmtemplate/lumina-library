import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/shared/controllers/lumina_profile_controller.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../../../../shared/models/profile/lumina_profile_models.dart';
import '../../../../shared/widgets/profile/lumina_profile_widgets.dart';

class LuminaProfilePage extends StatelessWidget {
  const LuminaProfilePage({
    super.key,
    required this.role,
  });

  final LuminaProfileRole role;

  String get _controllerTag => 'lumina-profile-${role.name}';

  LuminaProfileController get controller {
    if (Get.isRegistered<LuminaProfileController>(tag: _controllerTag)) {
      return Get.find<LuminaProfileController>(tag: _controllerTag);
    }

    return Get.put(
      LuminaProfileController(role: role),
      tag: _controllerTag,
    );
  }

  List<LuminaProfileMenuItemModel> get _accountItems {
    return const [
      LuminaProfileMenuItemModel(
        id: 'edit_profile',
        icon: Icons.person_outline_rounded,
        label: 'Edit Profile',
      ),
      LuminaProfileMenuItemModel(
        id: 'change_password',
        icon: Icons.lock_outline_rounded,
        label: 'Change Password',
      ),
    ];
  }

  List<LuminaProfileMenuItemModel> get _activityItems {
    return const [
      LuminaProfileMenuItemModel(
        id: 'borrowing_history',
        icon: Icons.history_rounded,
        label: 'Borrowing History',
      ),
      LuminaProfileMenuItemModel(
        id: 'payment_history',
        icon: Icons.receipt_long_rounded,
        label: 'Payment History',
      ),
    ];
  }

  List<LuminaProfileMenuItemModel> get _appPreferenceItems {
    return const [
      LuminaProfileMenuItemModel(
        id: 'notifications',
        icon: Icons.notifications_none_rounded,
        label: 'Notification Settings',
        description: 'Fitur ini akan segera tersedia.',
      ),
      LuminaProfileMenuItemModel(
        id: 'about',
        icon: Icons.info_outline_rounded,
        label: 'About',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final profileController = controller;

    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          Obx(() {
            final profile = profileController.profile.value;

            return LuminaProfileTopBar(
              title: profile.isStaff ? 'Profile' : 'Profil',
              showBackButton: profile.isStaff,
              showSettingsButton: !profile.isStaff,
              onBackTap: () => Get.back<void>(),
              onSettingsTap: profileController.openSettings,
            );
          }),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 672,
                ),
                child: RefreshIndicator(
                  onRefresh: profileController.refreshProfile,
                  child: Obx(() {
                    final profile = profileController.profile.value;
                    final isLoading = profileController.isLoading.value;
                    final hasError = profileController.hasError.value;

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        LuminaSpacing.marginMobile,
                        LuminaSpacing.lg,
                        LuminaSpacing.marginMobile,
                        LuminaSpacing.xl,
                      ),
                      children: [
                        if (isLoading)
                          const Padding(
                            padding: EdgeInsets.only(bottom: LuminaSpacing.sm),
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                        if (hasError) ...[
                          _ProfileErrorBanner(onRetry: profileController.refreshProfile),
                          const SizedBox(height: LuminaSpacing.md),
                        ],
                        LuminaProfileHeaderCard(
                          profile: profile,
                          subtitle: profileController.profileSubtitle,
                          isUploadingPhoto: profileController.isUploadingPhoto.value,
                          localAvatarFile: profileController.pendingAvatarFile.value,
                          onEditPhotoTap: profileController.editProfilePhoto,
                        ),
                        if (profile.hasStaffLibrary) ...[
                          const SizedBox(height: LuminaSpacing.lg),
                          LuminaStaffLibraryLocationCard(
                            profile: profile,
                            onOpenLocationTap: () {
                              profileController.handleMenuTap(
                                const LuminaProfileMenuItemModel(
                                  id: 'work_location',
                                  icon: Icons.location_on_rounded,
                                  label: 'Library Location',
                                ),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: LuminaSpacing.lg),
                        LuminaProfileStatsGrid(items: profileController.stats),
                        const SizedBox(height: LuminaSpacing.lg),
                        LuminaProfileInfoCard(items: profileController.infoRows),
                        const SizedBox(height: LuminaSpacing.lg),
                        LuminaProfileMenuCard(
                          sectionTitle: 'Account Settings',
                          items: _accountItems,
                          onItemTap: profileController.handleMenuTap,
                        ),
                        const SizedBox(height: LuminaSpacing.lg),
                        LuminaProfileMenuCard(
                          sectionTitle: 'Activity',
                          items: _activityItems,
                          onItemTap: profileController.handleMenuTap,
                        ),
                        const SizedBox(height: LuminaSpacing.lg),
                        LuminaProfileMenuCard(
                          sectionTitle: 'App Preferences',
                          items: _appPreferenceItems,
                          onItemTap: profileController.handleMenuTap,
                        ),
                        const SizedBox(height: LuminaSpacing.sm),
                        LuminaProfileLogoutButton(
                          onTap: () {
                            profileController.handleMenuTap(
                              const LuminaProfileMenuItemModel(
                                id: 'logout',
                                icon: Icons.logout_rounded,
                                label: 'Logout',
                                isDestructive: true,
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorBanner extends StatelessWidget {
  const _ProfileErrorBanner({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.md),
      decoration: BoxDecoration(
        color: LuminaColors.errorContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(color: LuminaColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: LuminaColors.error, size: 20),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Text(
              'Gagal memuat data profil terbaru.',
              style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.onErrorContainer, letterSpacing: 0),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
