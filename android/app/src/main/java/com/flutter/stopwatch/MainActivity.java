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

import androidx.activity.result.ActivityResultLauncher;
import androidx.activity.result.contract.ActivityResultContracts;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import android.widget.Toast;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import androidx.appcompat.app.AppCompatActivity;

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
        
        // requestNotificationPermission();
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

    // private final ActivityResultLauncher<String> requestPermissionLauncher =
    //     registerForActivityResult(new ActivityResultContracts.RequestPermission(), isGranted -> {
    //     if (isGranted) {
    //         // Permission is granted. You can now post notifications.
    //         Toast.makeText(this, "通知權限已獲取", Toast.LENGTH_SHORT).show();
    //         // Proceed with your notification-related logic
    //     } else {
    //         // Permission is denied. Handle the denial gracefully.
    //         Toast.makeText(this, "通知權限被拒絕", Toast.LENGTH_SHORT).show();
    //         // You might want to explain why the permission is needed or disable features
    //     }
    // });

    // private void requestNotificationPermission() {
    //     // For Android 13 (API level 33) and above, you need to request at runtime
    //     if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // TIRAMISU is API 33
    //         if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS)
    //                 == PackageManager.PERMISSION_GRANTED) {
    //             // Permission already granted
    //             Toast.makeText(this, "通知權限已獲取", Toast.LENGTH_SHORT).show();
    //             // Proceed with your notification-related logic
    //         } else if (shouldShowRequestPermissionRationale(Manifest.permission.POST_NOTIFICATIONS)) {
    //             // Explain to the user why the permission is needed (optional)
    //             // You can show a dialog here before requesting
    //             Toast.makeText(this, "我們需要通知權限才能發送重要更新。", Toast.LENGTH_LONG).show();
    //             requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS);
    //         } else {
    //             // Directly request the permission
    //             requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS);
    //         }
    //     } else {
    //         Toast.makeText(this, "您當前的 Android 版本不需要明確的通知權限請求。", Toast.LENGTH_SHORT).show();
    //     }
    // }

    @Override
    public void onDestroy() {
        super.onDestroy();
    }
}