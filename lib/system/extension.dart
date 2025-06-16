import 'dart:ui';

extension DurationExtension on Duration {
  String format() {
    var duration = "$this".split(".")[0];
    if (duration.startsWith("0:")) {
      duration = duration.substring(2);
    }
    return duration;
  }
}

extension StringnExtension on String {
  bool isNumeric() {
    RegExp numeric = RegExp(r'^-?[0-9]+$');
    return numeric.hasMatch(this);
  }
}

extension DateTimeFormatting on DateTime {
  // 格式化日期為指定格式的字符串
  String format({String pattern = "yy-MM-dd HH:mm:ss.ms"}) {
    final Map<String, String> replacements = {
      'yyyy': year.toString(),
      'yy': year.toString().substring(2, 4),
      'MM': _twoDigits(month),
      'dd': _twoDigits(day),
      'HH': _twoDigits(hour),
      'mm': _twoDigits(minute),
      'ss': _twoDigits(second),
      'ms': millisecond.toString().padLeft(3, '0'),
    };

    var formattedDate = pattern;
    replacements.forEach((key, value) {
      formattedDate = formattedDate.replaceAll(key, value);
    });

    return formattedDate;
  }

  // 將單位數轉換為兩位數的字符串
  String _twoDigits(int n) {
    return n.toString().padLeft(2, '0');
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${(255 * a).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(255 * r).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(255 * g).toInt().toRadixString(16).padLeft(2, '0')}'
      '${(255 * b).toInt().toRadixString(16).padLeft(2, '0')}';
}

extension SysColor on Color {
  static Color get primary => HexColor.fromHex("#3891D8");
  static Color get second => HexColor.fromHex("#cce2f3");
  static Color get gray => HexColor.fromHex("#eeeeee");
}
