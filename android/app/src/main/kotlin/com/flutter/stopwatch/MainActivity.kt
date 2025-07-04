package com.flutter.stopwatch

import com.flutter.StopWatch
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var stopWatch: StopWatch? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        stopWatch = StopWatch(flutterEngine)
    }

    override fun onDestroy() {
        super.onDestroy()
        stopWatch?.cleanup()
        stopWatch = null
    }
}