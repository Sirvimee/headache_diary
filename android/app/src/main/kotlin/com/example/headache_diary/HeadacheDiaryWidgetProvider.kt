package com.example.headache_diary

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HeadacheDiaryWidgetProvider : HomeWidgetProvider() {
    private val addSymptomAction = "com.example.headache_diary.ADD_SYMPTOM"

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(
                context.packageName,
                R.layout.headache_diary_widget,
            ).apply {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    action = addSymptomAction
                }
                val launchPendingIntent = PendingIntent.getActivity(
                    context,
                    widgetId,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                setOnClickPendingIntent(R.id.widget_container, launchPendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
