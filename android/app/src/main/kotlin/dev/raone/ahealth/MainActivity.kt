package dev.raone.ahealth

import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.work.WorkManager
import androidx.work.OneTimeWorkRequestBuilder
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch

class MainActivity : FlutterFragmentActivity() {

    private val scope = MainScope()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val stepPrefs = getSharedPreferences("step_prefs", MODE_PRIVATE)

        android.util.Log.d("StepSync", "onCreate step_prefs: ${stepPrefs.all}")
        val enabled = prefs.getBoolean("flutter.step_tracking_enabled", false)
        if (enabled) enqueueWork(this)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dev.raone.ahealth/tracking")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startTracking" -> {
                        enqueueWork(this)
                        result.success(true)
                    }
                    "stopTracking" -> {
                        WorkManager.getInstance(this).cancelUniqueWork("step_sync")
                        result.success(true)
                    }
                    "syncStepsNow" -> {
                        scope.launch {
                            try {
                                val worker = OneTimeWorkRequestBuilder<StepSyncWorker>().build()
                                WorkManager.getInstance(this@MainActivity).enqueue(worker)
                                result.success(true)
                            } catch (e: Exception) {
                                result.success(false)
                            }
                        }
                    }
                    "isBatteryOptimized" -> {
                        val pm = getSystemService(POWER_SERVICE) as android.os.PowerManager
                        result.success(!pm.isIgnoringBatteryOptimizations(packageName))
                    }
                    else -> result.notImplemented()
                }
            }
    }
}