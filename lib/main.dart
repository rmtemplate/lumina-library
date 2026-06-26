import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id', null);
  await initializeDateFormatting('id_ID', null);
  Intl.defaultLocale = 'id_ID';

  await GetStorage.init();

  runApp(const LuminaApp());
}