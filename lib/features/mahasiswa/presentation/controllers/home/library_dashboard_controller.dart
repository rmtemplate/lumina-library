import 'package:get/get.dart';

import 'package:lumina_library/shared/models/library/library_branch_model.dart';

class LibraryDashboardController extends GetxController {
  final RxBool showReminder = true.obs;

  final List<LibraryNearbyLibraryData> nearbyLibraries = const [
    LibraryNearbyLibraryData(
      id: 'lib-central',
      name: 'Perpustakaan Pusat Kampus',
      address: 'Gedung Rektorat Lt. 2, Area Kampus Utama',
      imageUrl:
          'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=900&q=80',
      distanceText: '350 m',
      durationText: '5 min',
      scheduleText: '08.00 - 20.00',
      openStatusText: 'Buka',
      isOpen: true,
      latitude: -6.200000,
      longitude: 106.816666,
    ),
    LibraryNearbyLibraryData(
      id: 'lib-tech',
      name: 'Perpustakaan Fakultas Teknologi',
      address: 'Gedung Fakultas Teknologi, Blok B',
      imageUrl:
          'https://images.unsplash.com/photo-1568667256549-094345857637?auto=format&fit=crop&w=900&q=80',
      distanceText: '720 m',
      durationText: '9 min',
      scheduleText: '08.00 - 18.00',
      openStatusText: 'Buka',
      isOpen: true,
      latitude: -6.201220,
      longitude: 106.817900,
    ),
    LibraryNearbyLibraryData(
      id: 'lib-journal',
      name: 'Ruang Jurnal & Referensi',
      address: 'Gedung Akademik Lt. 1, dekat Student Center',
      imageUrl:
          'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=900&q=80',
      distanceText: '1.1 km',
      durationText: '14 min',
      scheduleText: '09.00 - 16.00',
      openStatusText: 'Tutup',
      isOpen: false,
      latitude: -6.203110,
      longitude: 106.819001,
    ),
  ];

  void dismissReminder() {
    showReminder.value = false;
  }
}
