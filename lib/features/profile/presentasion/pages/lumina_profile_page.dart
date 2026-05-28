import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/shared/controllers/lumina_profile_controller.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_spacing.dart';
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
        id: 'change_password',
        icon: Icons.lock_outline_rounded,
        label: 'Change Password',
      ),
      LuminaProfileMenuItemModel(
        id: 'personal_information',
        icon: Icons.person_outline_rounded,
        label: 'Personal Information',
      ),
    ];
  }

  List<LuminaProfileMenuItemModel> get _appPreferenceItems {
    return const [
      LuminaProfileMenuItemModel(
        id: 'notifications',
        icon: Icons.notifications_none_rounded,
        label: 'Notifications',
      ),
      LuminaProfileMenuItemModel(
        id: 'language',
        icon: Icons.language_rounded,
        label: 'Language',
        trailingText: 'Bahasa Indonesia',
      ),
      LuminaProfileMenuItemModel(
        id: 'help_center',
        icon: Icons.help_outline_rounded,
        label: 'Help Center',
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
                child: Obx(() {
                  final profile = profileController.profile.value;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.lg,
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.xl,
                    ),
                    children: [
                      LuminaProfileHeaderCard(
                        profile: profile,
                        subtitle: profileController.profileSubtitle,
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
                      LuminaProfileMenuCard(
                        sectionTitle: 'Account Settings',
                        items: _accountItems,
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
        ],
      ),
    );
  }
}