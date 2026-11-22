package ee.meeli.migreenipaevik

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class HeadacheDiaryWidgetProvider : HomeWidgetProvider() {
    private companion object {
        const val ADD_SYMPTOM_ACTION = "com.example.headache_diary.ADD_SYMPTOM"
    }

    @Suppress("UNUSED_PARAMETER")
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
                    action = ADD_SYMPTOM_ACTION
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
