package com.sholatqibla.sholat_qibla

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Widget home screen Miqat: menampilkan sholat berikutnya + hitung mundur,
 * lengkap dengan ringkasan 5 waktu. Data diisi dari Flutter lewat
 * home_widget (SharedPreferences native), dibaca via HomeWidgetPlugin.
 */
class MiqatWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val prefs = HomeWidgetPlugin.getData(context)
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.miqat_widget)

            val nextName = prefs.getString("next_name", "—") ?: "—"
            val nextTime = prefs.getString("next_time", "") ?: ""
            val countdown = prefs.getString("next_countdown", "") ?: ""
            val cityName = prefs.getString("city_name", "") ?: ""
            val timesLine = prefs.getString("times_line", "") ?: ""

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
}
