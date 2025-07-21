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
import java.util.Map;

public class MainActivity extends FlutterActivity {
    String TAG = "StopWatch";
    private LocalNotification localNotification;
    public static MethodChannel.Result methodResult;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        GeneratedPluginRegistrant.registerWith(flutterEngine);

        localNotification = new LocalNotification(this);

        new MethodChannel(
                flutterEngine.getDartExecutor(),
                "com.flutter/MethodChannel")
                .setMethodCallHandler(mMethodHandle);
    }

    MethodChannel.MethodCallHandler mMethodHandle = new MethodChannel.MethodCallHandler() {
        @Override
        public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
            if(call.method.equals("sendNotification")) {
                Map<String, Object> arguments = call.arguments();
                String title = (String) arguments.get("title");
                String message = (String) arguments.get("message");
                
                Log.i(TAG, "sendNotification：" + message);
                localNotification.sendNotification(title, message);
                // result.success("OK");
                methodResult = result;
            } else {
                result.notImplemented();
            }

        }
    };

    @Override
    public void onDestroy() {
        super.onDestroy();
        methodResult = null;
        // mMethodHandle.cancel();
        mMethodHandle = null;
        localNotification.cancel();
        localNotification = null;
    }
}