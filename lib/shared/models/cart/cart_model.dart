/// Response model for GET/POST /api/v1/cart
/// Backend returns: { id, user_id, summary, groups: [ { branch, items } ] }
class CartModel {
  const CartModel({
    required this.id,
    required this.groups,
    required this.totalItems,
    required this.totalBranches,
  });

  final String id;
  final List<CartGroupModel> groups;
  final int totalItems;
  final int totalBranches;

  List<CartItemModel> get allItems =>
      groups.expand((g) => g.items).toList(growable: false);

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final rawGroups = json['groups'] as List<dynamic>? ?? [];

    return CartModel(
      id: json['id']?.toString() ?? '',
      totalItems: (summary['total_items'] as num?)?.toInt() ?? 0,
      totalBranches: (summary['total_branches'] as num?)?.toInt() ?? 0,
      groups: rawGroups
          .map((g) => CartGroupModel.fromJson(g as Map<String, dynamic>))
          .toList(),
    );
  }

  static CartModel empty() => const CartModel(
        id: '',
        groups: [],
        totalItems: 0,
        totalBranches: 0,
      );
}

class CartGroupModel {
  const CartGroupModel({
    required this.branch,
    required this.items,
    required this.itemsCount,
  });

  final CartBranchModel branch;
  final List<CartItemModel> items;
  final int itemsCount;

  factory CartGroupModel.fromJson(Map<String, dynamic> json) {
    final branchJson = json['branch'] as Map<String, dynamic>? ?? {};
    final rawItems = json['items'] as List<dynamic>? ?? [];

    return CartGroupModel(
      branch: CartBranchModel.fromJson(branchJson),
      itemsCount: (json['items_count'] as num?)?.toInt() ?? 0,
      items: rawItems
          .map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CartBranchModel {
  const CartBranchModel({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final String? code;
  final String? address;
  final double? latitude;
  final double? longitude;

  factory CartBranchModel.fromJson(Map<String, dynamic> json) {
    return CartBranchModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
      address: json['address']?.toString(),
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
    );
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class CartItemModel {
  const CartItemModel({
    required this.id,
    required this.cartId,
    required this.bookId,
    required this.branchId,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.isAvailable,
    required this.availableItems,
    this.isbn,
    this.publisher,
    this.publishYear,
    this.categoryName,
    this.ratingAverage = 0.0,
    this.ratingCount = 0,
    this.branchName = '',
    this.branchAddress,
  });

  final String id;
  final String cartId;
  final String bookId;
  final String branchId;
  final String title;
  final String author;
  final String? coverUrl;
  final bool isAvailable;
  final int availableItems;
  final String? isbn;
  final String? publisher;
  final int? publishYear;
  final String? categoryName;
  final double ratingAverage;
  final int ratingCount;
  final String branchName;
  final String? branchAddress;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final book = json['book'] as Map<String, dynamic>? ?? {};
    final branch = json['branch'] as Map<String, dynamic>? ?? {};
    final avail = json['availability'] as Map<String, dynamic>? ?? {};
    final rating = book['rating'] as Map<String, dynamic>? ?? {};
    final category = book['category'] as Map<String, dynamic>?;

    return CartItemModel(
      id: json['id']?.toString() ?? '',
      cartId: json['cart_id']?.toString() ?? '',
      bookId: json['book_id']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      title: book['title']?.toString() ?? '',
      author: book['author']?.toString() ?? '',
      coverUrl: book['cover_url']?.toString(),
      isbn: book['isbn']?.toString(),
      publisher: book['publisher']?.toString(),
      publishYear: (book['publish_year'] as num?)?.toInt(),
      categoryName: category?['name']?.toString(),
      ratingAverage: (rating['average'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (rating['count'] as num?)?.toInt() ?? 0,
      isAvailable: avail['is_available'] == true,
      availableItems: (avail['available_items'] as num?)?.toInt() ?? 0,
      branchName: branch['name']?.toString() ?? '',
      branchAddress: branch['address']?.toString(),
    );
  }
}
