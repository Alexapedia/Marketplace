import 'package:flutter/material.dart';

IconData categoryIcon(String name) {
  final n = name.toLowerCase();
  if (n.contains('watch') || n.contains('ساعة') || n.contains('ساعات')) {
    return Icons.watch_outlined;
  }
  if (n.contains('perfume') || n.contains('عطر') || n.contains('عود') || n.contains('مسك')) {
    return Icons.spa_outlined;
  }
  if (n.contains('cloth') || n.contains('ملابس') || n.contains('fashion')) {
    return Icons.checkroom_outlined;
  }
  if (n.contains('accessor') || n.contains('إكسسوار') || n.contains('اكسسوار') || n.contains('ring')) {
    return Icons.diamond_outlined;
  }
  return Icons.category_outlined;
}

Color? tryParseSwatch(String raw) {
  var s = raw.trim();
  if (s.startsWith('#')) {
    s = s.substring(1);
    if (s.length == 3) {
      s = s.split('').map((c) => '$c$c').join();
    }
    if (s.length == 6) {
      final n = int.tryParse(s, radix: 16);
      if (n != null) return Color(0xFF000000 | n);
    }
  }
  const named = <String, Color>{
    'black': Color(0xFF222222),
    'white': Color(0xFFFFFFFF),
    'navy': Color(0xFF071345),
    'gold': Color(0xFFC9A45C),
    'أسود': Color(0xFF222222),
    'ابيض': Color(0xFFFFFFFF),
    'أبيض': Color(0xFFFFFFFF),
    'ذهبي': Color(0xFFC9A45C),
    'كحلي': Color(0xFF071345),
  };
  return named[s] ?? named[s.toLowerCase()];
}
