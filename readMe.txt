1. 實體機器連線, 好像不行 2025-06-02
  1-1. Android 11 用無線偵錯
    1-1-1. Firebase Studio 的 termianl 下 adb connect ip:port
  1-2.  Android 10 用 USB 偵錯
    1-2-1. 在 MacBook termianl 下 adb tcpip 5555
    1-2-2. Firebase Studio 的 termianl 下 adb connect 192.168.0.232:5555

https://api.flutter.dev/flutter/material/Icons-class.html

adb -s emulator-5554 uninstall com.flutter.stopwatch

adb -s emulator-5554 shell ls storage/emulated/0
adb -s emulator-5554 shell mkdir storage/emulated/0/stopwatch
adb -s emulator-5554 shell ls storage/emulated/0/stopwatch

adb -s emulator-5554 push datafile/stopwatch.json storage/emulated/0/stopwatch
adb -s emulator-5554 push datafile/train.json storage/emulated/0/stopwatch
