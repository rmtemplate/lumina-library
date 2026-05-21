import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../widgets/library_app_top_bar.dart';
import '../widgets/library_menu_card.dart';
import '../widgets/library_profile_header_card.dart';
import '../widgets/library_stat_card.dart';

class LibraryProfilePage extends StatelessWidget {
  const LibraryProfilePage({super.key});

  static const String _avatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBvUfI0qnCR0Mqxq5OZ1UI-AKMt4ELnsfDVWA8DmzZgHBmANY-xDLsZpbv1OvvLuG8Indk0dXvCyW-JpSN85Y3AbQudS-3q1Qr2ZoOhPP93jXO3yaIM99_QLoM1LmQhpmry2TZCl0_reyaifv607bFXOCfTwCqytUn0rd1phuWfpZhBNg16w6tqc1-6BMFhZPG8RoSfoZC6XIhx_DqZYAJA8v6Qd_Hf-TBMLQWEMsISywvBSI7K9nd6zYQ5N4q90rt83KJAUUYJOa4P';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LuminaColors.background,
      child: Column(
        children: [
          const LibraryAppTopBar(
            title: 'Profil',
            leadingIcon: Icons.person_rounded,
            actionIcon: Icons.settings_rounded,
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                LuminaSpacing.marginMobile,
                LuminaSpacing.lg,
                LuminaSpacing.marginMobile,
                LuminaSpacing.xl,
              ),
              children: [
                LibraryProfileHeaderCard(
                  name: 'Budi Santoso',
                  studentId: '20210045678',
                  faculty: 'Fakultas Ilmu Komputer',
                  avatarUrl: _avatarUrl,
                  onEditTap: () {},
                ),
                const SizedBox(height: LuminaSpacing.lg),
                const _ProfileStatsGrid(),
                const SizedBox(height: LuminaSpacing.lg),
                LibraryMenuCard(
                  items: [
                    LibraryMenuItemData(
                      icon: Icons.person_outline_rounded,
                      title: 'Informasi Akun',
                      onTap: () {},
                    ),
                    LibraryMenuItemData(
                      icon: Icons.lock_outline_rounded,
                      title: 'Ubah Password',
                      onTap: () {},
                    ),
                    LibraryMenuItemData(
                      icon: Icons.payment_rounded,
                      title: 'Metode Pembayaran',
                      onTap: () {},
                    ),
                    LibraryMenuItemData(
                      icon: Icons.help_outline_rounded,
                      title: 'Bantuan & Dukungan',
                      onTap: () {},
                    ),
                    LibraryMenuItemData(
                      icon: Icons.logout_rounded,
                      title: 'Keluar',
                      isDestructive: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsGrid extends StatelessWidget {
  const _ProfileStatsGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LibraryStatCard(
                icon: Icons.menu_book_rounded,
                value: '42',
                label: 'Buku Dipinjam',
                iconBackgroundColor: LuminaColors.primaryFixed,
                iconColor: LuminaColors.onPrimaryFixed,
              ),
            ),
            SizedBox(width: LuminaSpacing.md),
            Expanded(
              child: LibraryStatCard(
                icon: Icons.book_online_rounded,
                value: '3',
                label: 'Aktif',
                iconBackgroundColor: LuminaColors.secondaryContainer,
                iconColor: LuminaColors.onSecondaryContainer,
              ),
            ),
          ],
        ),
        SizedBox(height: LuminaSpacing.md),
        LibraryStatCard(
          icon: Icons.account_balance_wallet_rounded,
          value: 'Rp 0',
          label: 'Total Denda',
          iconBackgroundColor: LuminaColors.errorContainer,
          iconColor: LuminaColors.onErrorContainer,
          valueColor: LuminaColors.error,
        ),
      ],
    );
  }
}
