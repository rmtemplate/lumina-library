import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/data/models/staff_member_model.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/features/staff/presentation/controllers/cart/staff_borrow_cart_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/member/staff_member_registration_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/qr_scanner/staff_qr_scanner_page.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';
import 'package:lumina_library/shared/widgets/popups/realtime_popup_shell.dart';

/// Step 2 of the staff Borrow flow — identify the member, either by
/// scanning their member QR/card or by searching manually. If no member is
/// found, Member Registration opens automatically (per spec: "If member
/// does NOT exist: Open Member Registration automatically").
class StaffMemberStepPage extends StatefulWidget {
  const StaffMemberStepPage({super.key});

  @override
  State<StaffMemberStepPage> createState() => _StaffMemberStepPageState();
}

class _StaffMemberStepPageState extends State<StaffMemberStepPage> {
  final TextEditingController _searchController = TextEditingController();
  List<StaffMemberModel> _results = [];
  bool _isSearching = false;
  bool _isConfirming = false;

  StaffBorrowCartController get _cart {
    if (Get.isRegistered<StaffBorrowCartController>()) {
      return Get.find<StaffBorrowCartController>();
    }
    return Get.put(StaffBorrowCartController(), permanent: true);
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await Get.find<StaffApiService>().searchMembers(query);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _scanMember() async {
    final raw = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const StaffQrScannerPage(
          title: 'Scan Student Borrow QR',
          description: 'Arahkan kamera ke kartu/QR member.',
        ),
      ),
    );

    if (raw == null || raw.trim().isEmpty || !mounted) return;

    try {
      final member = await Get.find<StaffApiService>().lookupMember(raw);
      if (!mounted) return;

      if (member == null) {
        await _openRegistrationAutomatically();
        return;
      }

      await _confirmBorrowing(member);
    } on LuminaApiException catch (e) {
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      LuminaToast.error('Gagal memeriksa member.');
    }
  }

  Future<void> _openRegistrationAutomatically() async {
    LuminaToast.info('Member tidak ditemukan — membuka pendaftaran member baru.');
    final registered = await Get.to<StaffMemberModel>(() => const StaffMemberRegistrationPage());
    if (registered != null && mounted) {
      await _confirmBorrowing(registered);
    }
  }

  Future<void> _confirmBorrowing(StaffMemberModel member) async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);

    try {
      final result = await Get.find<StaffApiService>().createBorrowing(
        memberId: member.id,
        bookItemIds: _cart.items.map((item) => item.id).toList(),
      );

      final borrowing = result['borrowing'] as Map<String, dynamic>? ?? {};

      if (!mounted) return;
      await RealtimePopupShell.show(
        context,
        icon: Icons.check_circle_rounded,
        iconColor: LuminaColors.secondary,
        iconBackgroundColor: LuminaColors.secondaryContainer.withOpacity(0.35),
        title: 'Peminjaman Berhasil!',
        message: '${_cart.count} buku dipinjamkan kepada ${member.fullname}.',
        borrowingCode: borrowing['borrowing_code']?.toString(),
        timeLabel: 'Member',
        timeValue: member.fullname,
        buttonLabel: 'Selesai',
      );

      _cart.clear();
      Get.until((route) => route.isFirst);
    } on LuminaApiException catch (e) {
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      LuminaToast.error('Gagal memproses peminjaman.');
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text('Identify Member', style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _isConfirming,
          child: Padding(
            padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isConfirming ? null : _scanMember,
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Scan Student Borrow QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LuminaColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                    ),
                  ),
                ),
                const SizedBox(height: LuminaSpacing.md),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: LuminaSpacing.sm),
                      child: Text('OR', style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: LuminaSpacing.md),
                TextField(
                  controller: _searchController,
                  onChanged: _search,
                  style: LuminaTextStyles.bodyMd.copyWith(
                    color: LuminaColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search member by name, email, phone, or NIM',
                    hintStyle: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.outline),
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: LuminaColors.surfaceContainerLow,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(LuminaRadius.md), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: LuminaSpacing.sm),
                Expanded(
                  child: _isSearching
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, _) => const SizedBox(height: LuminaSpacing.xs),
                          itemBuilder: (context, index) {
                            final member = _results[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: LuminaColors.primary.withOpacity(0.1),
                                backgroundImage: member.avatarUrl != null ? NetworkImage(member.avatarUrl!) : null,
                                child: member.avatarUrl == null ? const Icon(Icons.person_rounded, color: LuminaColors.primary) : null,
                              ),
                              title: Text(member.fullname,
                                  style: LuminaTextStyles.bodyMd.copyWith(
                                      color: LuminaColors.onSurface, fontWeight: FontWeight.w700)),
                              subtitle: Text(member.memberCode ?? member.email,
                                  style: LuminaTextStyles.labelMd.copyWith(
                                      color: LuminaColors.onSurfaceVariant, letterSpacing: 0)),
                              onTap: _isConfirming ? null : () => _confirmBorrowing(member),
                            );
                          },
                        ),
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: _isConfirming ? null : () => _openRegistrationAutomatically(),
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text('Register New Member'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
