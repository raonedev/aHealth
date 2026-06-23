package dev.raone.ahealth

import android.content.*
import androidx.work.*
import java.util.concurrent.TimeUnit

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
             // Reset baseline — TYPE_STEP_COUNTER resets to 0 on every reboot
            context.getSharedPreferences("step_prefs", Context.MODE_PRIVATE)
                .edit().putLong("last_step_count", 0L).apply()
            enqueueWork(context) // Re-schedule periodic sync after reboot
        }
    }
}

fun enqueueWork(context: Context) {
    val request = PeriodicWorkRequestBuilder<StepSyncWorker>(30, TimeUnit.MINUTES).build()
     // KEEP ensures duplicate tasks aren't created if already scheduled
    WorkManager.getInstance(context).enqueueUniquePeriodicWork(
        "step_sync", ExistingPeriodicWorkPolicy.KEEP, request
    )
}