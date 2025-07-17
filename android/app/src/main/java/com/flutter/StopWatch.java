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
    private LocalNotification notificationHelper;
    Context ctx;
    String TAG = "StopWatch";

    public StopWatch(Context ctx, FlutterEngine flutterEngine) {
        
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        this.ctx = ctx;
        notificationHelper = new LocalNotification(ctx);
        
        new MethodChannel(
                flutterEngine.getDartExecutor(),
                "com.flutter/MethodChannel")
                .setMethodCallHandler(mMethodHandle);


    }

    public void cleanup() {

    }

    MethodChannel.MethodCallHandler mMethodHandle = new MethodChannel.MethodCallHandler() {
        @Override
        public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
            if(call.method.equals("sendNotification")) {
                Log.i(TAG, "sendNotification");
                notificationHelper.sendNotification(
                        "新通知來囉！",
                        "這是一個從獨立類別發送的通知內容。"
                );

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

}