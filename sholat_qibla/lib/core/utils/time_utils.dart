import 'package:intl/intl.dart';

/// Format [Duration] menjadi string hitungan mundur yang ringkas.
///
/// Contoh:
/// - 1h 23m → "1j 23m"
/// - 0h 45m → "45m"
/// - 0h 00m 30s → "< 1m"
String formatCountdown(Duration d) {
  if (d.isNegative) return '0m';
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  if (hours > 0) return '$hours j $minutes m';
  if (minutes > 0) return '$minutes m';
  return '< 1 m';
}

/// Format [Duration] secara lebih detail dengan detik (untuk countdown tepat).
String formatCountdownFull(Duration d) {
  if (d.isNegative) return '00:00:00';
  final h = d.inHours.toString().padLeft(2, '0');
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$h:$m:$s';
}

/// Format [DateTime] menjadi "HH:mm" (24 jam).
String formatTime(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

/// Format [DateTime] menjadi tanggal lokal Indonesia.
/// Contoh: "Jumat, 3 Juli 2026"
String formatDateId(DateTime dt) {
  return DateFormat('EEEE, d MMMM yyyy', 'id').format(dt);
}
