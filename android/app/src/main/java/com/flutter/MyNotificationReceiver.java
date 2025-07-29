package com.flutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;
import androidx.core.app.NotificationManagerCompat;

public class MyNotificationReceiver extends BroadcastReceiver {
  public static final String ACTION_BUTTON_STOP = "com.flutter.stopwatch.ACTION_BUTTON_STOP";
  public static final String ACTION_BUTTON_NEXT = "com.flutter.stopwatch.ACTION_BUTTON_NEXT";
  public static final String EXTRA_NOTIFICATION_ID = "notification_id";

  @Override
  public void onReceive(Context context, Intent intent) {
    String action = intent.getAction();
    int notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 0);

    if (ACTION_BUTTON_STOP.equals(action)) {
      com.flutter.stopwatch.MainActivity.methodResult.success("STOP");
    } else if (ACTION_BUTTON_NEXT.equals(action)) {
      com.flutter.stopwatch.MainActivity.methodResult.success("NEXT");
    }

    // 點擊後可以取消通知 (可選)
    if (notificationId != 0) {
      NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
      notificationManager.cancel(notificationId);
    }
  }
}