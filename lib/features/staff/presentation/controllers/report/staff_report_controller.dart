import 'package:get/get.dart';

import 'package:lumina_library/core/theme/lumina_colors.dart';
import 'package:lumina_library/features/staff/presentation/models/staff_report_model.dart';

class StaffReportController extends GetxController {
  final RxString selectedPeriod = 'Oktober 2023'.obs;

  final List<BorrowTrendData> borrowTrends = const [
    BorrowTrendData(day: 'Sen', value: 40),
    BorrowTrendData(day: 'Sel', value: 60),
    BorrowTrendData(day: 'Rab', value: 85, isHighlighted: true),
    BorrowTrendData(day: 'Kam', value: 55),
    BorrowTrendData(day: 'Jum', value: 70),
    BorrowTrendData(day: 'Sab', value: 45),
  ];

  final List<PopularCategoryData> popularCategories = const [
    PopularCategoryData(
      name: 'Teknologi',
      percentage: 45,
      color: LuminaColors.primary,
    ),
    PopularCategoryData(
      name: 'Novel',
      percentage: 30,
      color: LuminaColors.secondaryFixedDim,
    ),
    PopularCategoryData(
      name: 'Sains',
      percentage: 25,
      color: LuminaColors.tertiaryFixedDim,
    ),
  ];

  final List<MostBorrowedBookData> mostBorrowedBooks = const [
    MostBorrowedBookData(
      title: 'Modern JavaScript Guide',
      borrowCount: 124,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCkDTy4TPeP6JzhfAsV9AVFfFT7ePddyq54VjKl3r28FZGvNmQWclBVFIgkcadU0FmaL1R6d1q-G9Yz9kCES1P8m9eYkL8Zd9htx7FjOI7xRMjtamK3FUhXh8Kj5y4vzyO6o463E-kU2n3rBGBaiySiUkpCO08t_h-j_RaWklE69tPDSTwUZapbweNO1eSLdoLl_R1vFwDt696dzvdPe3EIYmwJPbNnBdvdFf4OuZqp5yZ1xMmOwLHDsWdWgwn6t2nBRN_U0izsEGn4',
      trend: BookTrend.up,
    ),
    MostBorrowedBookData(
      title: 'Data Algorithms 101',
      borrowCount: 98,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAJbCek7Igi6EaE9SLCSxgCJt0-74eb1eYROK4XRWVXK0zhZLlQRl4w1IT1clbiddtCDbEfQ0NXzWi9UEHmHJx4HKamrDjS_dNt7DZ_EEQbaiZ0TGoyHejuXZdxSSlGWBjxYXaG18UaosuwXX_ZzORzzcqJahqrUQG9HKmIZ0H9SNHAvKxcxXym95uvBfntxAr2kVBrMxTej6VuNHOfSH5RJ7EWtnkmRtyXKK0mAzkdABdZujl3U08gRXpRTxPyGmE70zmCLgnB3_5J',
      trend: BookTrend.stable,
    ),
    MostBorrowedBookData(
      title: 'Advanced UI Principles',
      borrowCount: 86,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBElt0S_fsYNoINLJhUuINSubTOclcU6DkbjZkgHb6-PVbvE35UscoHIgXU5OSGkoceQdKBuzGaA54tcaApPw3peA9RAlfN-xPqppqLYfMqze9_MFaXrL4hlHJIDQ-0A2rIpTF6OHalVMB7F3XteW8VgE6PHZrirTdUw-rOmbJIhwKEsxdDDb2TKxvYtUAd1sF4LCPZx-ZzEdXEUPcWszLYhlelLr0PIZICkbVI_W3I9gvrVRUqW1E4PUtNiRGJatiMMRO1m-HduENs',
      trend: BookTrend.down,
    ),
  ];

  void setSelectedPeriod(String value) {
    if (value.trim().isEmpty) return;
    selectedPeriod.value = value;
  }
}
