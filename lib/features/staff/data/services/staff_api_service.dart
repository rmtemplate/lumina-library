import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:lumina_library/core/network/lumina_api_client.dart';
import 'package:lumina_library/features/staff/data/models/staff_book_item_model.dart';
import 'package:lumina_library/features/staff/data/models/staff_dashboard_summary_model.dart';
import 'package:lumina_library/features/staff/data/models/staff_member_model.dart';

/// Centralizes every Staff Module API call — dashboard, universal scan,
/// borrow-cart confirm, member registration/search/lookup, book
/// registration/search, reports. Mirrors PaymentApiService/ProfileApiService's
/// exact conventions (LuminaApiClient usage, debugPrint logging, error
/// propagation via LuminaApiException from the client itself).
class StaffApiService {
  const StaffApiService(this._client);

  final LuminaApiClient _client;

  /// GET /api/v1/staff/dashboard
  Future<StaffDashboardSummaryModel> getDashboard() async {
    final response = await _client.get<Map<String, dynamic>>(
      '/staff/dashboard',
      fromData: (data) => data as Map<String, dynamic>,
    );
    return StaffDashboardSummaryModel.fromJson(response.data ?? {});
  }

  /// POST /api/v1/staff/qr/scan — the ONE endpoint the Universal Scanner
  /// calls. Returns `{ type, data }` as a raw map — each scan-result page
  /// reads the slice of `data` it needs (shapes differ meaningfully by
  /// type, so a single rigid model would just be a pass-through anyway).
  Future<Map<String, dynamic>> universalScan(String raw) async {
    debugPrint('[STAFF][API] universalScan — raw length=${raw.length}');

    final response = await _client.post<Map<String, dynamic>>(
      '/staff/qr/scan',
      body: {'raw': raw},
      fromData: (data) => data as Map<String, dynamic>,
    );
    return response.data ?? {};
  }

  /// POST /api/v1/staff/returns/confirm
  Future<Map<String, dynamic>> confirmReturn({
    required String qrCode,
    required String borrowingId,
    required List<Map<String, dynamic>> items,
    String? staffNotes,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/staff/returns/confirm',
      body: {
        'qr_code': qrCode,
        'borrowing_id': borrowingId,
        'items': items,
        if (staffNotes != null) 'staff_notes': staffNotes,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );
    return response.data ?? {};
  }

  /// POST /api/v1/staff/borrowings — Borrow Cart confirm.
  Future<Map<String, dynamic>> createBorrowing({
    required String memberId,
    required List<String> bookItemIds,
    String? notes,
  }) async {
    debugPrint('[STAFF][API] createBorrowing — member=$memberId items=${bookItemIds.length}');

    final response = await _client.post<Map<String, dynamic>>(
      '/staff/borrowings',
      body: {
        'member_id': memberId,
        'book_item_ids': bookItemIds,
        if (notes != null) 'notes': notes,
      },
      fromData: (data) => data as Map<String, dynamic>,
    );
    return response.data ?? {};
  }

  /// GET /api/v1/staff/members/search?q=
  Future<List<StaffMemberModel>> searchMembers(String query) async {
    final response = await _client.get<List<dynamic>>(
      '/staff/members/search',
      query: {'q': query},
      fromData: (data) => data as List<dynamic>,
    );
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(StaffMemberModel.fromJson)
        .toList();
  }

  /// GET /api/v1/staff/members/lookup?code= — returns null if not found.
  Future<StaffMemberModel?> lookupMember(String code) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/staff/members/lookup',
      query: {'code': code},
      fromData: (data) => data as Map<String, dynamic>,
    );
    final data = response.data ?? {};
    if (data['found'] != true) return null;
    return StaffMemberModel.fromJson(data['member'] as Map<String, dynamic>);
  }

  /// POST /api/v1/staff/members — returns the generated password ONCE.
  Future<({StaffMemberModel member, String generatedPassword})> registerMember({
    required String studentId,
    required String fullname,
    required String email,
    required String phone,
    required String faculty,
    required String studyProgram,
    required String gender,
    String? address,
    File? photo,
  }) async {
    final fields = {
      'student_id': studentId,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'faculty': faculty,
      'study_program': studyProgram,
      'gender': gender,
      if (address != null) 'address': address,
    };

    final response = photo != null
        ? await _client.postMultipart<Map<String, dynamic>>(
            '/staff/members',
            fileField: 'photo',
            file: photo,
            fields: fields,
            fromData: (data) => data as Map<String, dynamic>,
          )
        : await _client.post<Map<String, dynamic>>(
            '/staff/members',
            body: fields,
            fromData: (data) => data as Map<String, dynamic>,
          );

    final data = response.data ?? {};
    return (
      member: StaffMemberModel.fromJson(data['user'] as Map<String, dynamic>),
      generatedPassword: data['generated_password']?.toString() ?? '',
    );
  }

  /// GET /api/v1/staff/books/search?q=
  Future<List<StaffBookItemModel>> searchBooks(String query) async {
    final response = await _client.get<List<dynamic>>(
      '/staff/books/search',
      query: {'q': query},
      fromData: (data) => data as List<dynamic>,
    );
    return (response.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(StaffBookItemModel.fromSearchJson)
        .toList();
  }

  /// POST /api/v1/staff/books — returns the registered book + generated
  /// per-copy QR images (base64 data URIs) ready to display/print.
  Future<Map<String, dynamic>> registerBook({
    String? isbn,
    required String bookCode,
    required String title,
    required String author,
    String? publisher,
    required String categoryId,
    String? rackId,
    required int quantity,
    File? cover,
  }) async {
    final fields = {
      if (isbn != null) 'isbn': isbn,
      'book_code': bookCode,
      'title': title,
      'author': author,
      if (publisher != null) 'publisher': publisher,
      'category_id': categoryId,
      if (rackId != null) 'rack_id': rackId,
      'quantity': '$quantity',
    };

    final response = cover != null
        ? await _client.postMultipart<Map<String, dynamic>>(
            '/staff/books',
            fileField: 'cover',
            file: cover,
            fields: fields,
            fromData: (data) => data as Map<String, dynamic>,
          )
        : await _client.post<Map<String, dynamic>>(
            '/staff/books',
            body: fields,
            fromData: (data) => data as Map<String, dynamic>,
          );

    return response.data ?? {};
  }

  /// GET /api/v1/staff/reports?period=
  Future<Map<String, dynamic>> getReport({String period = 'month'}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/staff/reports',
      query: {'period': period},
      fromData: (data) => data as Map<String, dynamic>,
    );
    return response.data ?? {};
  }

  /// GET /api/v1/staff/racks — Shelf/Location picker for Book Registration.
  Future<List<Map<String, dynamic>>> getRacks() async {
    final response = await _client.get<List<dynamic>>(
      '/staff/racks',
      fromData: (data) => data as List<dynamic>,
    );
    return (response.data ?? []).whereType<Map<String, dynamic>>().toList();
  }
}
