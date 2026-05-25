import 'package:flutter/material.dart';

import 'package:lumina_library/shared/widgets/form/lumina_search_field.dart';

class LibrarySearchBar extends LuminaSearchField {
  const LibrarySearchBar({
    super.key,
    required super.hintText,
    super.controller,
    super.onChanged,
    super.onFilterTap,
  }) : super(showFilterButton: true);
}
