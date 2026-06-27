import 'package:get/get.dart';

import 'package:lumina_library/core/network/lumina_api_exception.dart';
import 'package:lumina_library/features/mahasiswa/data/services/payment_api_service.dart';
import 'package:lumina_library/shared/models/payment/borrowing_payment_model.dart';

/// Consolidated staff payments list — Pending / Paid / Failed / Overdue /
/// Returned tabs, all backed by the same branch-scoped
/// GET /api/v1/staff/payments endpoint (filtered client-side by tab),
/// since `borrowing_status` (Overdue/Returned) and `status` (Pending/Paid/
/// Failed) are two different dimensions the backend doesn't pre-combine.
class StaffPaymentsController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;

  final List<String> tabs = const ['Pending', 'Paid', 'Failed', 'Overdue', 'Returned'];

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxList<BorrowingPaymentModel> _allPayments = <BorrowingPaymentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final service = Get.find<PaymentApiService>();
      final result = await service.staffList(perPage: 50);
      _allPayments.assignAll(result.items);
    } on LuminaApiException catch (e) {
      errorMessage.value = e.displayMessage;
    } catch (_) {
      errorMessage.value = 'Gagal memuat data pembayaran.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reload() => _load();

  void setTabIndex(int index) {
    if (index < 0 || index >= tabs.length) return;
    selectedTabIndex.value = index;
  }

  List<BorrowingPaymentModel> get filteredPayments {
    final tab = tabs[selectedTabIndex.value];
    return _allPayments.where((p) {
      switch (tab) {
        case 'Pending':
          return p.status == 'pending';
        case 'Paid':
          return p.status == 'paid';
        case 'Failed':
          return p.status == 'failed' || p.status == 'cancelled' || p.status == 'expired';
        case 'Overdue':
          return p.borrowingStatus == 'waiting_payment';
        case 'Returned':
          return p.borrowingStatus == 'returned' || p.borrowingStatus == 'returned_with_fine';
        default:
          return true;
      }
    }).toList(growable: false);
  }

  int countFor(String tab) {
    return _allPayments.where((p) {
      switch (tab) {
        case 'Pending':
          return p.status == 'pending';
        case 'Paid':
          return p.status == 'paid';
        case 'Failed':
          return p.status == 'failed' || p.status == 'cancelled' || p.status == 'expired';
        case 'Overdue':
          return p.borrowingStatus == 'waiting_payment';
        case 'Returned':
          return p.borrowingStatus == 'returned' || p.borrowingStatus == 'returned_with_fine';
        default:
          return false;
      }
    }).length;
  }
}
