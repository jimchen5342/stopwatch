package com.flutter.stopwatch;

import com.flutter.StopWatch;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    private StopWatch stopWatch;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        stopWatch = new StopWatch(this, flutterEngine);
        // requestNotificationPermission(); // 如果您需要權限處理，請取消註釋
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (stopWatch != null) {
            stopWatch.cleanup();
            stopWatch = null;
        }
    }
}