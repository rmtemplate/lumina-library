import 'package:flutter/material.dart';

class LuminaRadius {
  const LuminaRadius._();

  static const double sm = 4;
  static const double base = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;

  static BorderRadius get card => BorderRadius.circular(lg);
  static BorderRadius get button => BorderRadius.circular(md);
  static BorderRadius get input => BorderRadius.circular(md);
  static BorderRadius get chip => BorderRadius.circular(full);
  static BorderRadius get bookCover => BorderRadius.circular(sm);
  static BorderRadius get modal => BorderRadius.circular(xl);
}
