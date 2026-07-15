package com.muqibla.mu_qibla

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Widget home screen MU-Qibla: menampilkan sholat berikutnya + hitung mundur,
 * lengkap dengan ringkasan 5 waktu. Data diisi dari Flutter lewat
 * home_widget (SharedPreferences native), dibaca via HomeWidgetPlugin.
 */
class MuQiblaWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.mu_qibla_widget)

            val nextName = prefs.getString("next_name", "—") ?: "—"
            val nextTime = prefs.getString("next_time", "") ?: ""
            val cityName = prefs.getString("city_name", "") ?: ""
            val timesLine = prefs.getString("times_line", "") ?: ""

            // Hitung ulang sisa waktu dari epoch agar countdown tidak basi
            // antar refresh periodik (data string hanya fallback).
            // Dart int bisa tersimpan sebagai Int atau Long — baca aman.
            val nextEpoch = when (val v = prefs.all["next_epoch"]) {
                is Long -> v
                is Int -> v.toLong()
                else -> 0L
            }
            val countdown = if (nextEpoch > System.currentTimeMillis()) {
                formatRemaining(nextEpoch - System.currentTimeMillis())
            } else {
                prefs.getString("next_countdown", "") ?: ""
            }

            views.setTextViewText(R.id.widget_next_name, nextName)
            views.setTextViewText(R.id.widget_next_time, nextTime)
            views.setTextViewText(R.id.widget_countdown, countdown)
            views.setTextViewText(R.id.widget_city, cityName)
            views.setTextViewText(R.id.widget_times, timesLine)

            // Ketuk widget -> buka aplikasi.
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
                ?.apply { flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP }
            val pendingIntent = android.app.PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                android.app.PendingIntent.FLAG_UPDATE_CURRENT or
                    android.app.PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /** Format sisa waktu ala aplikasi: "1j 23m" atau "12m". */
    private fun formatRemaining(millis: Long): String {
        val totalMinutes = millis / 60000
        val hours = totalMinutes / 60
        val minutes = totalMinutes % 60
        return if (hours > 0) "${hours}j ${minutes.toString().padStart(2, '0')}m"
        else "${minutes}m"
    }
}
