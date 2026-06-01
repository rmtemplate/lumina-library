import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import 'package:lumina_library/core/services/lumina_storage_service.dart';
import 'package:lumina_library/features/mahasiswa/data/services/home_api_service.dart';
import 'package:lumina_library/shared/models/banner/banner_model.dart';
import 'package:lumina_library/shared/models/book/book_model.dart';
import 'package:lumina_library/shared/models/branch/branch_model.dart';
import 'package:lumina_library/shared/models/category/category_model.dart';
import 'package:lumina_library/shared/widgets/feedback/lumina_toast.dart';

class LibraryDashboardController extends GetxController {
  // ── Profile ──────────────────────────────────────────────────────────────
  final RxString userName = ''.obs;
  final RxnString userAvatarUrl = RxnString();

  // ── UI state ─────────────────────────────────────────────────────────────
  final RxBool showReminder = false.obs;

  // ── Banners ──────────────────────────────────────────────────────────────
  final RxBool bannersLoading = true.obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;

  // ── Categories ────────────────────────────────────────────────────────────
  final RxBool categoriesLoading = true.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;

  // ── Branches ─────────────────────────────────────────────────────────────
  final RxBool branchesLoading = true.obs;
  final RxList<BranchModel> nearbyBranches = <BranchModel>[].obs;

  // ── Trending books ────────────────────────────────────────────────────────
  final RxBool booksLoading = true.obs;
  final RxList<BookModel> trendingBooks = <BookModel>[].obs;

  HomeApiService get _service => Get.find<HomeApiService>();

  @override
  void onInit() {
    super.onInit();
    _loadCachedProfile();
    _fetchAll();
  }

  // ── Cached user ──────────────────────────────────────────────────────────

  void _loadCachedProfile() {
    final cached = LuminaStorageService.getUser();
    if (cached == null) return;

    final fullname = (cached['fullname'] as String?)?.trim() ?? '';
    userName.value = fullname.isNotEmpty ? fullname.split(' ').first : 'Kamu';
    userAvatarUrl.value = cached['avatar_url'] as String?;
  }

  // ── Fetch all ────────────────────────────────────────────────────────────

  Future<void> _fetchAll() async {
    await Future.wait([
      _fetchBanners(),
      _fetchCategories(),
      _fetchBranchesWithLocation(),
      _fetchTrendingBooks(),
      _fetchProfile(),
    ]);
  }

  Future<void> refresh() => _fetchAll();

  // ── Banners ──────────────────────────────────────────────────────────────

  Future<void> _fetchBanners() async {
    bannersLoading.value = true;
    try {
      final result = await _service.getBanners();
      banners.assignAll(result);
    } catch (_) {
      // Banner gagal → tidak perlu toast, widget kosong saja
    } finally {
      bannersLoading.value = false;
    }
  }

  // ── Categories ────────────────────────────────────────────────────────────

  Future<void> _fetchCategories() async {
    categoriesLoading.value = true;
    try {
      final result = await _service.getCategories();
      categories.assignAll(result);
    } catch (_) {
      // Kategori gagal → tidak perlu toast, slider tersembunyi
    } finally {
      categoriesLoading.value = false;
    }
  }

  // ── Branches ─────────────────────────────────────────────────────────────

  Future<void> _fetchBranchesWithLocation() async {
    branchesLoading.value = true;
    try {
      final position = await _getCurrentPosition();
      final result = await _service.getBranches(
        latitude: position?.latitude,
        longitude: position?.longitude,
      );
      nearbyBranches.assignAll(result);
    } catch (_) {
      LuminaToast.warning('Gagal memuat data perpustakaan.');
    } finally {
      branchesLoading.value = false;
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  // ── Trending books ────────────────────────────────────────────────────────

  Future<void> _fetchTrendingBooks() async {
    booksLoading.value = true;
    try {
      final result = await _service.getTrendingBooks(limit: 10);
      trendingBooks.assignAll(result);
    } catch (_) {
      LuminaToast.warning('Gagal memuat daftar buku.');
    } finally {
      booksLoading.value = false;
    }
  }

  // ── Profile ──────────────────────────────────────────────────────────────

  Future<void> _fetchProfile() async {
    try {
      final profile = await _service.getProfile();

      userName.value = profile.firstName;
      userAvatarUrl.value = profile.avatarUrl;

      // Perbarui cache storage
      final cached = LuminaStorageService.getUser() ?? {};
      cached['fullname'] = profile.fullname;
      cached['avatar_url'] = profile.avatarUrl;
      LuminaStorageService.saveUser(cached);
    } catch (_) {
      // Gunakan data cached, tidak perlu toast
    }
  }

  // ── Reminder ─────────────────────────────────────────────────────────────

  void dismissReminder() => showReminder.value = false;
}
