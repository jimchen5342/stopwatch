package com.flutter.stopwatch;

import androidx.annotation.NonNull;

import com.flutter.LocalNotification;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    String TAG = "StopWatch";
    public static EventChannel.EventSink eventSink;
    private LocalNotification notificationHelper;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        GeneratedPluginRegistrant.registerWith(flutterEngine);

        notificationHelper = new LocalNotification(this);

        new MethodChannel(
                flutterEngine.getDartExecutor(),
                "com.flutter/MethodChannel")
                .setMethodCallHandler(mMethodHandle);

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
             MainActivity.eventSink = eventSink;
        }

        @Override
        public void onCancel(Object o) {
        }
    };

    @Override
    public void onDestroy() {
        super.onDestroy();
//        if (stopWatch != null) {
//            stopWatch.cleanup();
//            stopWatch = null;
//        }
    }
}