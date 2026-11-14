package dev.raone.ahealth

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import com.istornz.live_activities.LiveActivityManager

class CustomLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val ctx: Context = context.applicationContext
    private val pendingIntent = PendingIntent.getActivity(
        ctx, 200,
        Intent(ctx, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>
    ): Notification {
        val title = data["title"] as? String ?: ""
        val distance = data["distance"] as? String ?: ""
        val elapsedText = data["elapsedText"] as? String ?: ""
        val startMs = (data["startMs"] as? Number)?.toLong() ?: System.currentTimeMillis()
        val running = data["running"] as? Boolean ?: true

        val rv = RemoteViews(ctx.packageName, R.layout.live_activity)
        rv.setTextViewText(R.id.la_title, title)
        rv.setTextViewText(R.id.la_distance, distance)

        if (running) {
            val base = SystemClock.elapsedRealtime() - (System.currentTimeMillis() - startMs)
            rv.setChronometer(R.id.la_timer, base, null, true)
            rv.setViewVisibility(R.id.la_timer, View.VISIBLE)
            rv.setViewVisibility(R.id.la_paused, View.GONE)
        } else {
            rv.setTextViewText(R.id.la_paused, elapsedText)
            rv.setViewVisibility(R.id.la_timer, View.GONE)
            rv.setViewVisibility(R.id.la_paused, View.VISIBLE)
        }

        return notification
            .setSmallIcon(ctx.applicationInfo.icon)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentTitle(title)
            .setContentText(distance)
            .setContentIntent(pendingIntent)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setCustomContentView(rv)
            .setCustomBigContentView(rv)
            .setCategory(Notification.CATEGORY_PROGRESS)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .build()
    }
}