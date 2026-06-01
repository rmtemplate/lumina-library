import 'package:lumina_library/shared/models/branch/branch_model.dart';

// ─── Sub-models ───────────────────────────────────────────────────────────────

/// Ringkasan stok buku di cabang (dari field `stock_summary`).
class BranchStockSummary {
  const BranchStockSummary({
    required this.totalStock,
    required this.availableStock,
  });

  final int totalStock;
  final int availableStock;

  factory BranchStockSummary.fromJson(Map<String, dynamic> json) {
    return BranchStockSummary(
      totalStock: (json['total_stock'] as num?)?.toInt() ?? 0,
      availableStock: (json['available_stock'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Ringkasan item buku per status (dari field `book_item_summary`).
class BranchBookItemSummary {
  const BranchBookItemSummary({
    required this.available,
    required this.borrowed,
    required this.reserved,
    required this.lost,
    required this.damaged,
  });

  final int available;
  final int borrowed;
  final int reserved;
  final int lost;
  final int damaged;

  int get total => available + borrowed + reserved + lost + damaged;

  factory BranchBookItemSummary.fromJson(Map<String, dynamic> json) {
    return BranchBookItemSummary(
      available: (json['available'] as num?)?.toInt() ?? 0,
      borrowed: (json['borrowed'] as num?)?.toInt() ?? 0,
      reserved: (json['reserved'] as num?)?.toInt() ?? 0,
      lost: (json['lost'] as num?)?.toInt() ?? 0,
      damaged: (json['damaged'] as num?)?.toInt() ?? 0,
    );
  }
}

// ─── Branch Detail ────────────────────────────────────────────────────────────

/// Detail lengkap cabang dari `GET /api/v1/public/branches/{id}`.
/// Menggunakan komposisi dengan [BranchModel] untuk menghindari duplikasi.
/// Tambahan field: stock_summary, book_item_summary
class BranchDetailModel {
  const BranchDetailModel({
    required this.branch,
    required this.stockSummary,
    required this.bookItemSummary,
  });

  /// Data cabang dasar — gunakan semua field dari sini.
  final BranchModel branch;
  final BranchStockSummary stockSummary;
  final BranchBookItemSummary bookItemSummary;

  // ── Shortcut getters ke BranchModel ────────────────────────────────────────
  String get id => branch.id;
  String get name => branch.name;
  String get address => branch.address;
  String? get imageUrl => branch.imageUrl;
  String? get description => branch.description;
  String? get phone => branch.phone;
  String? get email => branch.email;
  double? get latitude => branch.latitude;
  double? get longitude => branch.longitude;
  bool get isOpen => branch.schedule.isOpen;

  factory BranchDetailModel.fromJson(Map<String, dynamic> json) {
    final stockJson = json['stock_summary'] as Map<String, dynamic>?;
    final itemJson = json['book_item_summary'] as Map<String, dynamic>?;

    return BranchDetailModel(
      branch: BranchModel.fromJson(json),
      stockSummary: stockJson != null
          ? BranchStockSummary.fromJson(stockJson)
          : const BranchStockSummary(totalStock: 0, availableStock: 0),
      bookItemSummary: itemJson != null
          ? BranchBookItemSummary.fromJson(itemJson)
          : const BranchBookItemSummary(
              available: 0,
              borrowed: 0,
              reserved: 0,
              lost: 0,
              damaged: 0,
            ),
    );
  }
}
