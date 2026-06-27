package dev.raone.ahealth

import android.content.Context
import android.hardware.*
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.StepsRecord
import androidx.health.connect.client.records.metadata.Metadata
import androidx.health.connect.client.records.metadata.Device as HealthDevice
import androidx.work.*
import kotlinx.coroutines.*
import java.time.*
import kotlin.coroutines.*

class StepSyncWorker(ctx: Context, params: WorkerParameters) : CoroutineWorker(ctx, params) {

    override suspend fun doWork(): Result {
        val prefs = applicationContext.getSharedPreferences("step_prefs", Context.MODE_PRIVATE)
        val sensorManager = applicationContext.getSystemService(Context.SENSOR_SERVICE) as SensorManager

        val current = withTimeoutOrNull(5000) {
            readStepCounter(sensorManager)
        } ?: return Result.retry()

        val last = prefs.getLong("last_step_count", -1L)
        val lastTime = prefs.getLong("last_sync_time", System.currentTimeMillis())
        val now = System.currentTimeMillis()

        android.util.Log.d("StepSync", "current=$current, last=$last")
        android.util.Log.d("StepSync", "prefs all: ${prefs.all}")

        if (last == -1L) {
            prefs.edit().putLong("last_step_count", current).putLong("last_sync_time", now).commit()
            android.util.Log.d("StepSync", "Baseline saved: $current")
            return Result.success()
        }

        val delta = if (current < last) current else current - last
        android.util.Log.d("StepSync", "delta=$delta")
        if (delta > 0) {
            val success = writeToHealthConnect(delta, lastTime, now)
            if (!success) return Result.retry()
        }

        prefs.edit().putLong("last_step_count", current).putLong("last_sync_time", now).commit()
        return Result.success()
    }

    private suspend fun readStepCounter(sm: SensorManager): Long? {
        val sensor = sm.getDefaultSensor(Sensor.TYPE_STEP_COUNTER) ?: return null
        return suspendCancellableCoroutine { cont ->
            val listener = object : SensorEventListener {
                override fun onSensorChanged(e: SensorEvent) {
                    sm.unregisterListener(this)
                    if (cont.isActive) {
                        cont.resume(e.values[0].toLong())
                    }
                }
                override fun onAccuracyChanged(s: Sensor?, a: Int) {}
            }
            sm.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_NORMAL)
            cont.invokeOnCancellation { sm.unregisterListener(listener) }
        }
    }

    private suspend fun writeToHealthConnect(steps: Long, startMs: Long, endMs: Long): Boolean {
        return try {
            val client = HealthConnectClient.getOrCreate(applicationContext)
            val zoneOffset = ZoneOffset.systemDefault().rules.getOffset(Instant.now())
            
            client.insertRecords(listOf(
                StepsRecord(
                    count = steps,
                    startTime = Instant.ofEpochMilli(startMs),
                    endTime = Instant.ofEpochMilli(endMs),
                    startZoneOffset = zoneOffset,
                    endZoneOffset = zoneOffset,
                    metadata = Metadata.autoRecorded(
                        device = HealthDevice(

                            type = HealthDevice.TYPE_PHONE,
                            manufacturer = android.os.Build.MANUFACTURER, // Avoids hardcoded nulls
                            model = android.os.Build.MODEL               // Provides better context
                        )
                    )
                )
            ))
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}