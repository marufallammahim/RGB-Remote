package com.marufallammahim.rgbremote

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class SmartControlWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_smart_controls)

            val onIntent = Intent(context, SmartControlReceiver::class.java)
                .setAction(SmartControlActions.LIGHT_ON)
            val offIntent = Intent(context, SmartControlReceiver::class.java)
                .setAction(SmartControlActions.LIGHT_OFF)

            views.setOnClickPendingIntent(
                R.id.widget_light_on,
                PendingIntent.getBroadcast(
                    context, 4101, onIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )
            views.setOnClickPendingIntent(
                R.id.widget_light_off,
                PendingIntent.getBroadcast(
                    context, 4102, offIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
            )
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    companion object {
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val provider = ComponentName(context, SmartControlWidgetProvider::class.java)
            val ids = manager.getAppWidgetIds(provider)
            if (ids.isNotEmpty()) {
                SmartControlWidgetProvider().onUpdate(context, manager, ids)
            }
        }
    }
}
