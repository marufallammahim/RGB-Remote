package com.marufallammahim.rgbremote

import android.content.Context

object SmartControlPreferences {
    private const val PREFS_NAME = "rgb_remote_smart_controls"
    private const val KEY_LIGHT_ON = "light_on_pattern"
    private const val KEY_LIGHT_OFF = "light_off_pattern"

    const val LIGHT_ON_ID = "rgb_remote_light_on"
    const val LIGHT_OFF_ID = "rgb_remote_light_off"

    fun save(context: Context, onPattern: String, offPattern: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_LIGHT_ON, onPattern)
            .putString(KEY_LIGHT_OFF, offPattern)
            .apply()
    }

    fun getPattern(context: Context, controlId: String): String? {
        val key = when (controlId) {
            LIGHT_ON_ID -> KEY_LIGHT_ON
            LIGHT_OFF_ID -> KEY_LIGHT_OFF
            else -> return null
        }
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(key, null)
    }
}
