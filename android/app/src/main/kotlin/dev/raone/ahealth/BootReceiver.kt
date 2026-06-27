package dev.raone.ahealth

import android.content.*
import androidx.work.*
import java.util.concurrent.TimeUnit

class BootReceiver : BroadcastReceiver() {
    //    override fun onReceive(context: Context, intent: Intent) {
//        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
//            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
//            val enabled = prefs.getBoolean("flutter.step_tracking_enabled", false)
//            if (enabled) {
//                context.getSharedPreferences("step_prefs", Context.MODE_PRIVATE)
//                    .edit().putLong("last_step_count", -1L).commit()
//                enqueueWork(context)
//            }
//        }
//    }
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val prefs =
                context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val enabled = prefs.getBoolean("flutter.step_tracking_enabled", false)
            if (enabled) {
                // Don't reset to -1, let worker handle reboot by detecting current < last
                enqueueWork(context)
            }
        }
    }
}

fun enqueueWork(context: Context) {
    val request = PeriodicWorkRequestBuilder<StepSyncWorker>(30, TimeUnit.MINUTES).build()
    WorkManager.getInstance(context).enqueueUniquePeriodicWork(
        "step_sync", ExistingPeriodicWorkPolicy.KEEP, request
    )
}