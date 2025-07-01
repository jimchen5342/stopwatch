extension SecondsToString on num {
  String toChinese() {
    // 格式化時間，將秒數轉換為 HH:mm:ss 格式
    var str = "";
    final hours = (this ~/ 3600);
    final minutes = ((this % 3600) ~/ 60);
    final seconds = (this % 60);
    if (hours > 0) {
      str += "$hours 小時";
    }

    if (minutes > 0) {
      str +=
          "${str.isEmpty ? '' : ', '}$minutes 分${hours == 0 && seconds == 0 ? '鐘' : ''}";
    }
    if (seconds > 0) {
      str +=
          "${str.isEmpty ? '' : ', '}$seconds 秒${hours == 0 && minutes == 0 ? '鐘' : ''}";
    }
    return str;
  }

  // 格式化時間，將秒數轉換為 HH:mm:ss 格式
  String toFormat() {
    final hours = (this ~/ 3600); // .toString().padLeft(2, '0');
    final minutes = ((this % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (this % 60).toString().padLeft(2, '0');
    var h = "";
    if (hours > 0) {
      h = "${hours.toString().padLeft(2, '0')}:";
    }
    return "$h$minutes:$seconds";
  }
}
