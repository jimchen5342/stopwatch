package com.flutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.widget.Toast;
import androidx.core.app.NotificationManagerCompat;

public class MyNotificationReceiver extends BroadcastReceiver {
  public static final String ACTION_BUTTON_1 = "com.example.app.ACTION_BUTTON_1";
  public static final String ACTION_BUTTON_2 = "com.example.app.ACTION_BUTTON_2";
  public static final String EXTRA_NOTIFICATION_ID = "notification_id";

  @Override
  public void onReceive(Context context, Intent intent) {
    String action = intent.getAction();
    int notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 0);

    if (ACTION_BUTTON_1.equals(action)) {
      // 處理按鈕 1 的點擊
      Toast.makeText(context, "按鈕 1 被點擊 (Java)", Toast.LENGTH_SHORT).show();
    } else if (ACTION_BUTTON_2.equals(action)) {
      // 處理按鈕 2 的點擊
      Toast.makeText(context, "按鈕 2 被點擊 (Java)", Toast.LENGTH_SHORT).show();
    }

    // 點擊後可以取消通知 (可選)
    if (notificationId != 0) {
      NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
      notificationManager.cancel(notificationId);
    }
  }
}