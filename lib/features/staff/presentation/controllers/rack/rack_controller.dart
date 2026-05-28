import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/rack_management_models.dart';

class RackController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  final RxString searchKeyword = ''.obs;
  final RxList<RackModel> racks = <RackModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    if (racks.isEmpty) {
      racks.assignAll(_buildDummyRacks());
    }
  }

  List<RackModel> get filteredRacks {
    final keyword = searchKeyword.value.trim();

    if (keyword.isEmpty) {
      return racks.toList(growable: false);
    }

    return racks.where((rack) {
      return rack.matchesKeyword(keyword);
    }).toList(growable: false);
  }

  bool get isSearching => searchKeyword.value.trim().isNotEmpty;

  void setSearchKeyword(String value) {
    searchKeyword.value = value;
  }

  void clearSearch() {
    searchController.clear();
    searchKeyword.value = '';
  }

  RackModel? findRackById(String rackId) {
    for (final rack in racks) {
      if (rack.id == rackId) return rack;
    }

    return null;
  }

  BookModel? findBookById(String bookId) {
    for (final rack in racks) {
      for (final book in rack.books) {
        if (book.id == bookId) return book;
      }
    }

    return null;
  }

  List<BookModel> findBooksByIds(List<String> bookIds) {
    final idSet = bookIds.toSet();
    final result = <BookModel>[];

    for (final rack in racks) {
      for (final book in rack.books) {
        if (idSet.contains(book.id)) {
          result.add(book);
        }
      }
    }

    return result;
  }

  bool moveBooks({
    required String sourceRackId,
    required String destinationRackId,
    required List<String> bookIds,
  }) {
    if (sourceRackId == destinationRackId) return false;
    if (bookIds.isEmpty) return false;

    final sourceIndex = racks.indexWhere((rack) => rack.id == sourceRackId);
    final destinationIndex = racks.indexWhere(
      (rack) => rack.id == destinationRackId,
    );

    if (sourceIndex < 0 || destinationIndex < 0) return false;

    final destinationRack = racks[destinationIndex];

    if (destinationRack.availableSlot < bookIds.length) {
      Get.snackbar(
        'Rak tujuan penuh',
        'Rak ${destinationRack.rackCode} hanya memiliki ${destinationRack.availableSlot} slot tersedia.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      return false;
    }

    final selectedBookIds = bookIds.toSet();
    final sourceRack = racks[sourceIndex];

    final movedBooks = sourceRack.books.where((book) {
      return selectedBookIds.contains(book.id);
    }).toList(growable: false);

    if (movedBooks.isEmpty) return false;

    final remainingSourceBooks = sourceRack.books.where((book) {
      return !selectedBookIds.contains(book.id);
    }).toList(growable: false);

    final updatedMovedBooks = movedBooks.map((book) {
      return book.copyWith(rackId: destinationRackId);
    }).toList(growable: false);

    racks[sourceIndex] = sourceRack.copyWith(
      books: remainingSourceBooks,
    );

    racks[destinationIndex] = destinationRack.copyWith(
      books: [
        ...destinationRack.books,
        ...updatedMovedBooks,
      ],
    );

    racks.refresh();
    return true;
  }

  List<RackModel> _buildDummyRacks() {
    const cover1 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBLclXHkvHRHCHg5pDk6pbG79ZxoABVMCi0D-Bj4M6xhAqW_LJwlGvZAGsmPb8srE8SflMdR0RKBXH8Q3qcSyOHQZBaFhLhPBjX080K-Ug3zPruHZB95qOtq5cxf5xXgDN1zOC2_F4LHhYUA1sSKQHQZj4Z9z2oQ5JwBm7_3X9MR96XbG1iu6mwgRIgnVvZ2qBrzZG0RojmZHmsa1_qtO88KGkdlO0JDF9D7a0SBX0GdRXnktCXqvVekcWK314Z5Lf07fPVZDs7UiYW';

    const cover2 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAuLblMAj5-Sc853TMVBkmebmIs-PlqkXA2dmSvr6np_PuAApRlgf0J9jxiwcJG-BsSUs9oKsn9ksyb3dfmzQtUydS6lc_1Emw_aOukz22O2jzIOC5ET0JGAZPFPxzTDSKEO6OxtFcm8Y1QzTh_5wPP2qQnP16DxscNnWv0X2BEi3lbQy24UysKZ_Nlcp3o9laV40glwhEHh3O_B_WOOlWdZaJyeJ0CcHF3IAk6jCbHn4pSCtzT110s7C5aIff8AVMeosutYK3qGFaj';

    const cover3 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDFtPY08koMch_TVNgxI6NG7PM-FzVmki-eENqsbHPdiuTqJu53S19Rzzuewotosw7fpA0BOHSo8u7rp6esH0z9z5YDAxVCXI_bzCry3t2jfErzsR1AiXaPQXuNq7LbPqn66Y4Etk5eNNFqTyLivYkxyOLMgrY-vZHr9t0bgMIxjpV4YYwLIEArvxee0cMXce9RbIcVXWbU2212IwPLDheL0tnZ9PaKoLvCmeYiUVIvp8QyzcMe0klsbfG_WcUMaUflq3inhdk7qVmg';

    const cover4 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuCO34Y508de6iKw_qzLC6_2khlv2bRyBx7h4XorhVHnkzkfFsZrBK2DSPcgTd44O7j5m5-RkYK8pzR8LEimeUNuEwz1stpZtQih_LSmdcghLYsPq2SQ9qjWWab5_2CnsV6Zqq3xuxpo2Oq24iCXn2k0i0lsSg-QZ6iYM_UMoNAFOsE5t6pdyclTmaKDagds72W3NKb4tDwSuaAiebME6HzI6wZi5Wjo71jnzKrk2tUmrhhNjaH8xS2LmGL6n-eW3WasselkmOJZo1N9';

    const cover5 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDEqwKBnH8vr-PuYXSy-6DZAa4WouAOjyZyx_VITYRgXX4O-V6P91OszSCt6POwHB-N3EqTfV_FxrGpEBPDYWt7aQHuepWAppe-0kAkpYVcV4rW0Xo5oflqor5X0LsySQdvSBetLpMUj--CtpaPsIY0NWRunpbDxpAimtXprYZ9FpWPwVo8A5FkIq0Z2YnX9fno3vayr12fwde3Ls9uIsVOzW54MWruq8G3QgkgleR4gHF4sQFr27d0d-0GU-mILt1lXSU5qQDyErXJ';

    return [
      RackModel(
        id: 'rack-novel',
        rackCode: '1RN002',
        name: 'Rak Novel',
        sectionName: 'Literature Section',
        floorLabel: 'Lantai 1',
        areaLabel: 'Area Novel',
        aisleCode: 'Lorong N-02',
        capacity: 72,
        notes: 'Rak utama koleksi novel populer dan literatur umum.',
        books: const [
          BookModel(
            id: 'book-novel-1',
            title: 'Sapiens',
            author: 'Yuval Noah Harari',
            cover: cover5,
            rackId: 'rack-novel',
            catalogCode: 'NOV 001',
          ),
          BookModel(
            id: 'book-novel-2',
            title: 'The Design of Everyday Things',
            author: 'Don Norman',
            cover: cover3,
            rackId: 'rack-novel',
            catalogCode: 'NOV 002',
          ),
          BookModel(
            id: 'book-novel-3',
            title: 'Thinking, Fast and Slow',
            author: 'Daniel Kahneman',
            cover: cover1,
            rackId: 'rack-novel',
            catalogCode: 'NOV 003',
          ),
        ],
      ),
      RackModel(
        id: 'rack-tech',
        rackCode: '2RT014',
        name: 'Rak Teknologi',
        sectionName: 'Computer Science Section',
        floorLabel: 'Lantai 2',
        areaLabel: 'Technology Zone',
        aisleCode: 'Lorong T-14',
        capacity: 80,
        notes: 'Koleksi teknologi, pemrograman, dan sistem informasi.',
        books: const [
          BookModel(
            id: 'book-tech-1',
            title: 'Clean Architecture',
            author: 'Robert C. Martin',
            cover: cover2,
            rackId: 'rack-tech',
            catalogCode: 'TEC 101',
          ),
          BookModel(
            id: 'book-tech-2',
            title: 'Clean Code',
            author: 'Robert C. Martin',
            cover: cover4,
            rackId: 'rack-tech',
            catalogCode: 'TEC 102',
          ),
          BookModel(
            id: 'book-tech-3',
            title: 'Quantum Mechanics',
            author: 'Richard P. Feynman',
            cover: cover1,
            rackId: 'rack-tech',
            catalogCode: 'QC 174.12 .F4',
          ),
        ],
      ),
      RackModel(
        id: 'rack-history',
        rackCode: '1RH011',
        name: 'Rak Sejarah',
        sectionName: 'History Section',
        floorLabel: 'Lantai 1',
        areaLabel: 'History Wing',
        aisleCode: 'Lorong H-11',
        capacity: 64,
        notes: 'Koleksi sejarah dunia, peradaban, dan budaya.',
        books: const [
          BookModel(
            id: 'book-history-1',
            title: 'Guns, Germs, and Steel',
            author: 'Jared Diamond',
            cover: cover5,
            rackId: 'rack-history',
            catalogCode: 'HIS 201',
          ),
          BookModel(
            id: 'book-history-2',
            title: 'The Silk Roads',
            author: 'Peter Frankopan',
            cover: cover3,
            rackId: 'rack-history',
            catalogCode: 'HIS 202',
          ),
        ],
      ),
      RackModel(
        id: 'rack-comic',
        rackCode: 'B1RC009',
        name: 'Rak Komik',
        sectionName: 'Comic & Graphic Novel',
        floorLabel: 'Basement B1',
        areaLabel: 'Entertainment Corner',
        aisleCode: 'Lorong C-09',
        capacity: 60,
        isBasement: true,
        notes: 'Koleksi komik dan graphic novel di area basement.',
        books: const [],
      ),
      RackModel(
        id: 'rack-reference',
        rackCode: '3RR001',
        name: 'Rak Referensi',
        sectionName: 'Reference Section',
        floorLabel: 'Lantai 3',
        areaLabel: 'Quiet Academic Wing',
        aisleCode: 'Lorong R-01',
        capacity: 3,
        notes: 'Rak referensi akademik. Saat ini sudah penuh.',
        books: const [
          BookModel(
            id: 'book-ref-1',
            title: 'Academic Writing Handbook',
            author: 'Stephen Bailey',
            cover: cover1,
            rackId: 'rack-reference',
            catalogCode: 'REF 001',
          ),
          BookModel(
            id: 'book-ref-2',
            title: 'Research Methods',
            author: 'John W. Creswell',
            cover: cover2,
            rackId: 'rack-reference',
            catalogCode: 'REF 002',
          ),
          BookModel(
            id: 'book-ref-3',
            title: 'Library Classification',
            author: 'Melvil Dewey',
            cover: cover3,
            rackId: 'rack-reference',
            catalogCode: 'REF 003',
          ),
        ],
      ),
    ];
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}