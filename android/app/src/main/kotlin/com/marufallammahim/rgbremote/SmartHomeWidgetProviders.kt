package com.marufallammahim.rgbremote

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

internal object SmartHomeWidgetBinder {
    fun update(
        context: Context,
        manager: AppWidgetManager,
        ids: IntArray,
        layoutId: Int
    ) {
        ids.forEach { widgetId ->
            val views = RemoteViews(context.packageName, layoutId)
            if (layoutId != R.layout.widget_smart_controls_compact) {
                bindAction(context, views, widgetId, R.id.widget_light_on, SmartControlActions.LIGHT_ON, 6101)
                bindAction(context, views, widgetId, R.id.widget_light_off, SmartControlActions.LIGHT_OFF, 6102)
            }
            bindAction(context, views, widgetId, R.id.widget_light_white, SmartControlActions.WHITE, 6103)
            manager.updateAppWidget(widgetId, views)
        }
    }

    private fun bindAction(
        context: Context,
        views: RemoteViews,
        widgetId: Int,
        viewId: Int,
        action: String,
        requestBase: Int
    ) {
        val intent = Intent(context, SmartControlReceiver::class.java).setAction(action)
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            requestBase + widgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(viewId, pendingIntent)
    }
}

class SmartControlCompactWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        SmartHomeWidgetBinder.update(context, manager, ids, R.layout.widget_smart_controls_compact)
    }
}

class SmartControlPanelWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        SmartHomeWidgetBinder.update(context, manager, ids, R.layout.widget_smart_controls_panel)
    }
}
