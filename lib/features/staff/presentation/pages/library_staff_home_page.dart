import 'package:flutter/material.dart';

import '../../../../core/theme/lumina_colors.dart';
import '../../../../core/theme/lumina_radius.dart';
import '../../../../core/theme/lumina_spacing.dart';
import '../../../../core/theme/lumina_text_styles.dart';
import '../widgets/library_staff_bottom_nav_bar.dart';
import 'library_staff_dashboard_page.dart';
import 'staff_qr_scanner_page.dart';

class LibraryStaffHomePage extends StatefulWidget {
  const LibraryStaffHomePage({super.key});

  @override
  State<LibraryStaffHomePage> createState() => _LibraryStaffHomePageState();
}

class _LibraryStaffHomePageState extends State<LibraryStaffHomePage> {
  int _selectedIndex = 0;

  void _onNavigationChanged(int index) {
    // Index 1 adalah tombol tengah QR Scanner.
    // Jangan ubah state bottom nav, langsung redirect/push page.
    if (index == 1) {
      _goToQrScannerPage();
      return;
    }

    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _goToQrScannerPage() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const StaffQrScannerPage(),
      ),
    );

    if (!mounted || result == null || result.trim().isEmpty) return;

    // Nanti bisa dipakai untuk refresh dashboard / hit API hasil scan.
    debugPrint('QR scan result: $result');
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const LibraryStaffDashboardPage();

      case 2:
        return const _StaffReportsPage();

      default:
        return const LibraryStaffDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: _buildCurrentPage(),
      bottomNavigationBar: LibraryStaffBottomNavBar(
        currentIndex: _selectedIndex,
        onChanged: _onNavigationChanged,
      ),
    );
  }
}

class _StaffReportsPage extends StatelessWidget {
  const _StaffReportsPage();

  @override
  Widget build(BuildContext context) {
    return const _StaffPlaceholderPage(
      icon: Icons.analytics_rounded,
      title: 'Reports',
      description:
          'Halaman laporan untuk aktivitas peminjaman, pengembalian, dan keterlambatan.',
    );
  }
}

class _StaffPlaceholderPage extends StatelessWidget {
  const _StaffPlaceholderPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: LuminaColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(LuminaSpacing.xl),
              decoration: BoxDecoration(
                color: LuminaColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(LuminaRadius.xl),
                border: Border.all(
                  color: LuminaColors.surfaceVariant,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: LuminaColors.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: LuminaColors.primary,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: LuminaSpacing.lg),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: LuminaTextStyles.headlineSm.copyWith(
                      color: LuminaColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: LuminaSpacing.xs),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: LuminaTextStyles.bodyMd.copyWith(
                      color: LuminaColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}