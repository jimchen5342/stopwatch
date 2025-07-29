package com.flutter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;
import androidx.core.app.NotificationManagerCompat;
import com.flutter.stopwatch.MainActivity;

public class MyNotificationReceiver extends BroadcastReceiver {
  public static final String ACTION_BUTTON_STOP = "com.flutter.stopwatch.ACTION_BUTTON_STOP";
  public static final String ACTION_BUTTON_NEXT = "com.flutter.stopwatch.ACTION_BUTTON_NEXT";
  public static final String EXTRA_NOTIFICATION_ID = "notification_id";

  @Override
  public void onReceive(Context context, Intent intent) {
    String action = intent.getAction();
    int notificationId = intent.getIntExtra(EXTRA_NOTIFICATION_ID, 0);

    if (MainActivity.methodResult != null) {
      if (ACTION_BUTTON_STOP.equals(action)) {
        MainActivity.methodResult.success("STOP");
      } else if (ACTION_BUTTON_NEXT.equals(action)) {
        MainActivity.methodResult.success("NEXT");
      }
    } else {
      Log.w("StopWatchReceiver", "methodResult was null, action: " + action + ". The event will be lost.");
    }

 
    if (notificationId != 0) { // 點擊後可以取消通知
      NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
      notificationManager.cancel(notificationId);
    }

    // 將 App 帶到前景，沒有效；2025-07-29
    Intent launchIntent = new Intent(context, MainActivity.class);
    launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
    context.startActivity(launchIntent);
    // Log.w("StopWatchReceiver", "App brought to foreground with action: " + action);

  }
}