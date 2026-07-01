import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/core/theme/lumina_radius.dart';
import 'package:lumina_library/core/theme/lumina_spacing.dart';
import 'package:lumina_library/core/theme/lumina_text_styles.dart';
import 'package:lumina_library/features/staff/data/models/staff_book_item_model.dart';
import 'package:lumina_library/features/staff/data/services/staff_api_service.dart';
import 'package:lumina_library/features/staff/presentation/controllers/cart/staff_borrow_cart_controller.dart';
import 'package:lumina_library/features/staff/presentation/pages/member/staff_member_step_page.dart';
import 'package:lumina_library/features/staff/presentation/pages/scan/staff_scan_page.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

/// Borrow Cart — scanned/searched books staff is about to lend out. Supports
/// multiple books, removing a book, continuing to scan, manual search, and
/// clearing the cart before proceeding to member identification.
class StaffBorrowCartPage extends StatelessWidget {
  const StaffBorrowCartPage({super.key});

  StaffBorrowCartController get _cart {
    if (Get.isRegistered<StaffBorrowCartController>()) {
      return Get.find<StaffBorrowCartController>();
    }
    return Get.put(StaffBorrowCartController(), permanent: true);
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Semua buku di keranjang akan dihapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _cart.clear();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Clear', style: TextStyle(color: LuminaColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _openManualSearch(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ManualBookSearchSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = _cart;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      appBar: AppBar(
        backgroundColor: LuminaColors.surface,
        elevation: 0,
        foregroundColor: LuminaColors.primary,
        title: Text(
          'Borrow Cart',
          style: LuminaTextStyles.titleLg.copyWith(color: LuminaColors.primary, fontWeight: FontWeight.w900),
        ),
        actions: [
          Obx(() => cart.isEmpty
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: () => _confirmClear(context),
                  child: const Text('Clear', style: TextStyle(color: LuminaColors.error)),
                )),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (cart.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(LuminaSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_basket_outlined, size: 56, color: LuminaColors.outline),
                    const SizedBox(height: LuminaSpacing.sm),
                    Text(
                      'Keranjang masih kosong. Scan atau cari buku untuk mulai.',
                      textAlign: TextAlign.center,
                      style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              LuminaSpacing.marginMobile,
              LuminaSpacing.lg,
              LuminaSpacing.marginMobile,
              LuminaSpacing.md,
            ),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: LuminaSpacing.sm),
            itemBuilder: (context, index) {
              final item = cart.items[index];
              return _CartItemTile(item: item, onRemove: () => cart.removeItem(item.id));
            },
          );
        }),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(LuminaSpacing.marginMobile),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(() => const StaffScanPage()),
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: const Text('Scan More'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: LuminaColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                      ),
                    ),
                  ),
                  const SizedBox(width: LuminaSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openManualSearch(context),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text('Search'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: LuminaColors.secondary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LuminaSpacing.sm),
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: cart.isEmpty ? null : () => Get.to(() => const StaffMemberStepPage()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LuminaColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: LuminaColors.outlineVariant,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(LuminaRadius.full)),
                      ),
                      child: Text(
                        'Proceed Borrow (${cart.count})',
                        style: LuminaTextStyles.titleSm.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item, required this.onRemove});

  final StaffBookItemModel item;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LuminaSpacing.sm),
      decoration: BoxDecoration(
        color: LuminaColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(LuminaRadius.lg),
        border: Border.all(color: LuminaColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 64,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: LuminaColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(LuminaRadius.sm),
            ),
            child: item.coverUrl != null
                ? Image.network(item.coverUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.menu_book_rounded, color: LuminaColors.primary))
                : const Icon(Icons.menu_book_rounded, color: LuminaColors.primary),
          ),
          const SizedBox(width: LuminaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.bookTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: LuminaTextStyles.bodyMd.copyWith(color: LuminaColors.onSurface, fontWeight: FontWeight.w800)),
                Text(item.bookAuthor, maxLines: 1, overflow: TextOverflow.ellipsis, style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.outline, letterSpacing: 0)),
                Text(item.itemCode, style: LuminaTextStyles.labelMd.copyWith(color: LuminaColors.secondary, letterSpacing: 0, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline_rounded, color: LuminaColors.error),
          ),
        ],
      ),
    );
  }
}

class _ManualBookSearchSheet extends StatefulWidget {
  const _ManualBookSearchSheet();

  @override
  State<_ManualBookSearchSheet> createState() => _ManualBookSearchSheetState();
}

class _ManualBookSearchSheetState extends State<_ManualBookSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  List<StaffBookItemModel> _results = [];
  bool _isSearching = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await Get.find<StaffApiService>().searchBooks(query);
      setState(() {
        _results = results;
        _isSearching = false;
      });
    } on LuminaApiException catch (e) {
      setState(() => _isSearching = false);
      LuminaToast.error(e.displayMessage);
    } catch (_) {
      setState(() => _isSearching = false);
      LuminaToast.error('Gagal mencari buku.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Get.isRegistered<StaffBorrowCartController>()
        ? Get.find<StaffBorrowCartController>()
        : Get.put(StaffBorrowCartController(), permanent: true);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: LuminaColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(LuminaSpacing.marginMobile, LuminaSpacing.md, LuminaSpacing.marginMobile, LuminaSpacing.md),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(color: LuminaColors.outlineVariant, borderRadius: BorderRadius.circular(999)),
              ),
              const SizedBox(height: LuminaSpacing.md),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _search,
                style: LuminaTextStyles.bodyMd.copyWith(
                  color: LuminaColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Title, ISBN, barcode, book code, or author',
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
                        controller: scrollController,
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: LuminaSpacing.xs),
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          return ListTile(
                            leading: const Icon(Icons.menu_book_rounded, color: LuminaColors.primary),
                            title: Text(item.bookTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LuminaTextStyles.bodyMd.copyWith(
                                    color: LuminaColors.onSurface, fontWeight: FontWeight.w700)),
                            subtitle: Text('${item.itemCode} · ${item.bookAuthor}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: LuminaTextStyles.labelMd.copyWith(
                                    color: LuminaColors.onSurfaceVariant, letterSpacing: 0)),
                            trailing: const Icon(Icons.add_circle_outline_rounded, color: LuminaColors.secondary),
                            onTap: () {
                              cart.addItem(item);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
