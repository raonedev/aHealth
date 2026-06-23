package dev.raone.ahealth

import android.content.Context
import android.hardware.*
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.units.Energy
import androidx.work.*
import kotlinx.coroutines.*
import java.time.*
import java.util.concurrent.TimeUnit
import kotlin.coroutines.*

class StepSyncWorker(ctx: Context, params: WorkerParameters) : CoroutineWorker(ctx, params) {

    override suspend fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences("step_prefs", Context.MODE_PRIVATE)
        val sensorManager = applicationContext.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        // Read current cumulative step count from hardware sensor (resets on reboot)
        val current = readStepCounter(sensorManager) ?: return Result.retry()
        val last = prefs.getLong("last_step_count", -1L)
        val lastTime = prefs.getLong("last_sync_time", System.currentTimeMillis())
        val now = System.currentTimeMillis()

        if (last == -1L) {
             // First run — save baseline, nothing to sync yet
            prefs.edit().putLong("last_step_count", current).putLong("last_sync_time", now).apply()
            return Result.success()
        }

        val delta = current - last // Steps taken since last sync
        if (delta > 0) writeToHealthConnect(delta, lastTime, now)
        
        // Save current state for next sync cycle
        prefs.edit().putLong("last_step_count", current).putLong("last_sync_time", now).apply()
        return Result.success()
    }

    private suspend fun readStepCounter(sm: SensorManager): Long? {
         // TYPE_STEP_COUNTER is a hardware counter — OS maintains it even when app is dead
        val sensor = sm.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) ?: return null
        return suspendCancellableCoroutine { cont ->
            val listener = object : SensorEventListener {
                override fun onSensorChanged(e: SensorEvent) {
                    sm.unregisterListener(this) // Unregister immediately after single read
                    cont.resume(e.values[0].toLong())
                }
                override fun onAccuracyChanged(s: Sensor?, a: Int) {}
            }
            sm.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_NORMAL)
            cont.invokeOnCancellation { sm.unregisterListener(listener) } // Cleanup on timeout/cancel
        }
    }

    private suspend fun writeToHealthConnect(steps: Long, startMs: Long, endMs: Long) {
        val client = HealthConnectClient.getOrCreate(applicationContext)
        val zoneOffset = ZoneOffset.systemDefault().rules.getOffset(Instant.now())
        // Insert step delta as a single record covering the last sync window
        client.insertRecords(listOf(
            StepsRecord(
                count = steps,
                startTime = Instant.ofEpochMilli(startMs),
                endTime = Instant.ofEpochMilli(endMs),
                startZoneOffset = zoneOffset,
                endZoneOffset = zoneOffset,
            )
        ))
    }
}