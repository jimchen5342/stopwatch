package com.flutter;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.Log;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import androidx.annotation.NonNull;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.os.Build;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;


public class StopWatch {
    public static EventChannel.EventSink eventSink;
    private static final String CHANNEL = "com.flutter/stopwatch";
    private static final String CHANNEL_ID = "stopwatch_channel_id";
    private static final CharSequence CHANNEL_NAME = "Stopwatch Channel";
    private static final String CHANNEL_DESCRIPTION = "Notifications for the Stopwatch app";


    public StopWatch(FlutterEngine flutterEngine) {
        Log.i("StopWatch", "initital");
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        
        new MethodChannel(
                flutterEngine.getDartExecutor(),
                "com.flutter/MethodChannel")
                .setMethodCallHandler(mMethodHandle);

        createNotificationChannel();

    }

    public void cleanup() {

    }

    MethodChannel.MethodCallHandler mMethodHandle = new MethodChannel.MethodCallHandler() {
        @Override
        public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
            if(call.method.equals("getBatteryLevel")) { // 可以用的，2025-07-04
                result.success("OK");
            } else {
                result.notImplemented();
            }

        }
    };
    EventChannel.StreamHandler mEnventHandle = new EventChannel.StreamHandler() {
        @Override
        public void onListen(Object o, EventChannel.EventSink eventSink) {
            // MainActivity.eventSink = eventSink;
        }

        @Override
        public void onCancel(Object o) {
        }
    };

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, CHANNEL_NAME, importance);
            channel.setDescription(CHANNEL_DESCRIPTION);
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }
    }

    private void showNotification() {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setSmallIcon(android.R.drawable.ic_dialog_info) // 請替換成您自己的 icon
                .setContentTitle("Stopwatch Notification")
                .setContentText("This is a sample notification from Stopwatch app.")
                .setPriority(NotificationCompat.PRIORITY_DEFAULT);

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(this);
        // notificationId is a unique int for each notification that you must define
        notificationManager.notify(1, builder.build());
    }
}