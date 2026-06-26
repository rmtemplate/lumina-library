import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lumina_library/features/staff/presentation/pages/rack/manage_rack_page.dart';

import '../../../../../core/theme/lumina_colors.dart';
import '../../../../../core/theme/lumina_spacing.dart';
import '../../../../../shared/widgets/feedback/lumina_toast.dart';
import '../../controllers/rack/rack_controller.dart';
import '../../widgets/rack/rack_management_widgets.dart';

class RackListPage extends StatelessWidget {
  const RackListPage({
    super.key,
  });

  RackController get controller {
    if (Get.isRegistered<RackController>()) {
      return Get.find<RackController>();
    }

    return Get.put(
      RackController(),
      permanent: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final rackController = controller;

    return Scaffold(
      backgroundColor: LuminaColors.background,
      body: Column(
        children: [
          Obx(() {
            final totalRack = rackController.racks.length;
            final filteredRack = rackController.filteredRacks.length;

            return RackTopAppBar(
              title: 'Rak Buku',
              subtitle: rackController.isSearching
                  ? '$filteredRack hasil ditemukan'
                  : '$totalRack rak tersedia • Kelola lokasi koleksi',
              showSearch: true,
              searchController: rackController.searchController,
              searchHintText: 'Cari rak, kode rak, lantai, area...',
              onSearchChanged: rackController.setSearchKeyword,
              onSearchClear: rackController.clearSearch,
              onLeadingTap: Get.back,
              trailingIcon: Icons.tune_rounded,
              onTrailingTap: () {
                LuminaToast.info('Filter lanjutan belum tersedia.');
              },
            );
          }),
          Expanded(
            child: Obx(() {
              final racks = rackController.filteredRacks;

              if (racks.isEmpty && rackController.isSearching) {
                return EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  title: 'Rak Tidak Ditemukan',
                  description:
                      'Tidak ada rak yang cocok dengan "${rackController.searchKeyword.value}". Coba gunakan kode rak, lantai, atau area lain.',
                );
              }

              if (racks.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.inventory_2_outlined,
                  title: 'Belum Ada Rak',
                  description: 'Tambahkan rak untuk mulai mengelola buku.',
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 760,
                  ),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.lg,
                      LuminaSpacing.marginMobile,
                      LuminaSpacing.xl,
                    ),
                    itemCount: racks.length,
                    separatorBuilder: (_, _) {
                      return const SizedBox(height: LuminaSpacing.md);
                    },
                    itemBuilder: (context, index) {
                      final rack = racks[index];

                      return RackCard(
                        rack: rack,
                        onTap: () {
                          Get.to(
                            () => ManageRackPage(
                              rackId: rack.id,
                            ),
                            transition: Transition.cupertino,
                          );
                        },
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}