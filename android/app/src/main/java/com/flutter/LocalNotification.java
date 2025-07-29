package com.flutter;

import io.flutter.Log;

import android.Manifest;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import com.flutter.stopwatch.R;
import com.flutter.MyNotificationReceiver;


public class LocalNotification {
  private static final String CHANNEL_ID = "stopwatch_local_notification";
  private static final int NOTIFICATION_ID = 888;

  private Context context;

  public LocalNotification(Context context) {
    this.context = context;
  }

  /**
   * 發送本地通知。
   * @param title 通知標題
   * @param message 通知內容
   */
  public void sendNotification(String title, String message) {
    // 建立 PendingIntent 給按鈕 1
    Intent intentButton1 = new Intent(context, MyNotificationReceiver.class);
    intentButton1.setAction(MyNotificationReceiver.ACTION_BUTTON_STOP);
    intentButton1.putExtra(MyNotificationReceiver.EXTRA_NOTIFICATION_ID, NOTIFICATION_ID);
    PendingIntent pendingIntentButton1 = PendingIntent.getBroadcast(
            context,
            0, // requestCode
            intentButton1,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
    );

    // 建立 PendingIntent 給按鈕 2
    Intent intentButton2 = new Intent(context, MyNotificationReceiver.class);
    intentButton2.setAction(MyNotificationReceiver.ACTION_BUTTON_NEXT);
    intentButton2.putExtra(MyNotificationReceiver.EXTRA_NOTIFICATION_ID, NOTIFICATION_ID);
    PendingIntent pendingIntentButton2 = PendingIntent.getBroadcast(
            context,
            1, // requestCode 必須不同，如果 Intent 的其他部分相同
            intentButton2,
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
    );

    // 建立 NotificationCompat.Action
    NotificationCompat.Action actionStop = new NotificationCompat.Action.Builder(
            android.R.drawable.btn_star_big_on, // 替換為您的圖示資源
            "Stop",
            pendingIntentButton1
    ).build();



    NotificationCompat.Builder builder = new NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.running) // 替換為您的通知小圖示
            .setContentTitle(title) // "計時碼錶-" +
            .setContentText(message)
            .setPriority(NotificationCompat.PRIORITY_HIGH) // 設定高優先級
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC) // 設定在鎖定螢幕上顯示完整內容
            .addAction(actionStop)
            .setAutoCancel(true); // 點擊通知主體時自動取消 (可選)
    /* 還沒有寫
    NotificationCompat.Action actionNext = new NotificationCompat.Action.Builder(
            android.R.drawable.star_big_on, // 替換為您的圖示資源
            "Next",
            pendingIntentButton2
    ).build();
    builder.addAction(actionNext);
    */

    NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);

    // Android Oreo (API 26) 及以上版本需要 NotificationChannel
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      CharSequence channelName = title;
      String channelDescription = message;
      int importance = NotificationManager.IMPORTANCE_HIGH;
      NotificationChannel channel = new NotificationChannel(CHANNEL_ID, channelName, importance);
      channel.setDescription(channelDescription);
      // 您可以在這裡設定頻道的其他屬性，例如是否在鎖定螢幕上顯示通知
      channel.setLockscreenVisibility(NotificationCompat.VISIBILITY_PUBLIC); // 或 android.app.Notification.VISIBILITY_PUBLIC
      notificationManager.createNotificationChannel(channel);
    }

    // 顯示通知
    // 在實際應用中，確保您有 POST_NOTIFICATIONS 權限 (Android 13+)
      if (ActivityCompat.checkSelfPermission(context, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
          // TODO: Consider calling
          //    ActivityCompat#requestPermissions
          // here to request the missing permissions, and then overriding
          //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
          //                                          int[] grantResults)
          // to handle the case where the user grants the permission. See the documentation
          // for ActivityCompat#requestPermissions for more details.
          return;
      }
      notificationManager.notify(NOTIFICATION_ID, builder.build());
  }

  public void cancel() {
    NotificationManagerCompat notificationManager = NotificationManagerCompat.from(context);
      notificationManager.cancel(NOTIFICATION_ID);
  }
}
