package com.marufallammahim.rgbremote

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.widget.Toast

object SmartControlActions {
    const val LIGHT_ON = "com.marufallammahim.rgbremote.SMART_LIGHT_ON"
    const val LIGHT_OFF = "com.marufallammahim.rgbremote.SMART_LIGHT_OFF"
    const val WHITE = "com.marufallammahim.rgbremote.SMART_WHITE"
}

class SmartControlReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val controlId = when (intent.action) {
            SmartControlActions.LIGHT_ON -> SmartControlPreferences.LIGHT_ON_ID
            SmartControlActions.LIGHT_OFF -> SmartControlPreferences.LIGHT_OFF_ID
            SmartControlActions.WHITE -> SmartControlPreferences.WHITE_ID
            else -> return
        }
        val pendingResult = goAsync()
        val pattern = SmartControlPreferences.getPattern(context, controlId)
        if (pattern.isNullOrBlank()) {
            showMessage(context, "Open RGB Remote once to prepare Smart Controls.")
            pendingResult.finish()
            return
        }

        IrTransmissionEngine.submit(
            context,
            pattern,
            onSuccess = { pendingResult.finish() },
            onError = { error ->
                android.util.Log.e("RGBRemoteSmart", "Smart control IR transmission failed", error)
                showMessage(context, error.message ?: "IR transmission failed.")
                pendingResult.finish()
            }
        )
    }

    private fun showMessage(context: Context, message: String) {
        Handler(Looper.getMainLooper()).post {
            Toast.makeText(context.applicationContext, message, Toast.LENGTH_SHORT).show()
        }
    }
}
