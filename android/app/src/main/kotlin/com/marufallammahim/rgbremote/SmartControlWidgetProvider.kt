package com.marufallammahim.rgbremote

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context

class SmartControlWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        SmartHomeWidgetBinder.update(context, appWidgetManager, appWidgetIds, R.layout.widget_smart_controls)
    }

    companion object {
        fun refresh(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(android.content.ComponentName(context, SmartControlWidgetProvider::class.java))
            if (ids.isNotEmpty()) SmartControlWidgetProvider().onUpdate(context, manager, ids)
        }
    }
}
