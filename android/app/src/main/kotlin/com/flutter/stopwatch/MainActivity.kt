package com.flutter.stopwatch

import com.flutter.StopWatch
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private var stopWatch: StopWatch? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        stopWatch = StopWatch(this, flutterEngine)
        requestNotificationPermission()
    }

    override fun onDestroy() {
        super.onDestroy()
        stopWatch?.cleanup()
        stopWatch = null
    }

    private val requestPermissionLauncher: ActivityResultLauncher<String> =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted: Boolean ->
        if (isGranted) {
            // 權限已獲取。您現在可以發送通知了。
            Toast.makeText(this, "通知權限已獲取", Toast.LENGTH_SHORT).show()
            // 繼續您的通知相關邏輯
        } else {
            // 權限被拒絕。優雅地處理拒絕情況。
            Toast.makeText(this, "通知權限被拒絕", Toast.LENGTH_SHORT).show()
            // 您可能需要解釋為什麼需要此權限或禁用相關功能
        }
    }

    private fun requestNotificationPermission() {
        // 對於 Android 13 (API level 33) 及更高版本，您需要在執行時請求
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // TIRAMISU 是 API 33
            when {
                ContextCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) == PackageManager.PERMISSION_GRANTED -> {
                    // 權限已授予
                    Toast.makeText(this, "通知權限已獲取", Toast.LENGTH_SHORT).show()
                    // 繼續您的通知相關邏輯
                }
                shouldShowRequestPermissionRationale(Manifest.permission.POST_NOTIFICATIONS) -> {
                    // 向用戶解釋為什麼需要此權限（可選）
                    // 您可以在此處在請求前顯示一個對話框
                    Toast.makeText(this, "我們需要通知權限才能發送重要更新。", Toast.LENGTH_LONG).show()
                    requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                }
                else -> {
                    // 直接請求權限
                    requestPermissionLauncher.launch(Manifest.permission.POST_NOTIFICATIONS)
                }
            }
        } else {
            // 對於 Android 13 以下的版本，如果已在清單中聲明，則 POST_NOTIFICATIONS 會自動授予。
            // 您無需在執行時明確請求它。
            Toast.makeText(this, "您目前的 Android 版本不需要明確的通知權限請求。", Toast.LENGTH_SHORT).show()
            // 繼續您的通知相關邏輯
        }
    }  

}