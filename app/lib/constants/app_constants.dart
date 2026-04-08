import 'package:flutter/material.dart';

class AppColors {
  static const bgPage    = Color(0xFFF1F5F9);
  static const bgCard    = Color(0xFFFFFFFF);
  static const bgHeader  = Color(0xFF0F172A);
  static const primary   = Color(0xFF1E73BE);
  static const primaryL  = Color(0xFFEFF6FF);
  static const gold      = Color(0xFFF59E0B);
  static const goldL     = Color(0xFFFEF3C7);
  static const green     = Color(0xFF16A34A);
  static const greenWA   = Color(0xFF25D366);
  static const red       = Color(0xFFDC2626);
  static const textPri   = Color(0xFF0F172A);
  static const textSec   = Color(0xFF475569);
  static const textMut   = Color(0xFF94A3B8);
  static const border    = Color(0xFFE2E8F0);
  static const divider   = Color(0xFFF1F5F9);

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];
}

class K {
  static const baseUrl = 'https://shillongteeroffice.com';
  static const apiBase = '$baseUrl/api';
  static const refreshSec = 30;
}

Color levelColor(int lv) => [
  const Color(0xFF64748B),
  const Color(0xFF1E73BE),
  const Color(0xFFF59E0B),
  const Color(0xFFDC2626),
][lv.clamp(0, 3)];

Color levelBg(int lv) => [
  const Color(0xFFF1F5F9),
  const Color(0xFFEFF6FF),
  const Color(0xFFFEF3C7),
  const Color(0xFFFEE2E2),
][lv.clamp(0, 3)];
