package com.marufallammahim.rgbremote

import android.annotation.TargetApi
import android.app.PendingIntent
import android.content.Intent
import android.os.Build
import android.service.controls.Control
import android.service.controls.ControlsProviderService
import android.service.controls.DeviceTypes
import android.service.controls.actions.CommandAction
import android.service.controls.actions.ControlAction
import android.service.controls.templates.StatelessTemplate
import java.util.concurrent.Flow
import java.util.function.Consumer

@TargetApi(Build.VERSION_CODES.R)
class SmartControlsProviderService : ControlsProviderService() {

    override fun createPublisherForAllAvailable(): Flow.Publisher<Control> {
        val controls = listOf(
            createAvailableControl(SmartControlPreferences.LIGHT_ON_ID, "LIGHT ON", 5101),
            createAvailableControl(SmartControlPreferences.LIGHT_OFF_ID, "LIGHT OFF", 5102)
        )
        return publisher(controls, completeAfterEmission = true)
    }

    override fun createPublisherFor(controlIds: List<String>): Flow.Publisher<Control> {
        val controls = controlIds.mapNotNull { id ->
            when (id) {
                SmartControlPreferences.LIGHT_ON_ID ->
                    createActionControl(id, "LIGHT ON", 5201)
                SmartControlPreferences.LIGHT_OFF_ID ->
                    createActionControl(id, "LIGHT OFF", 5202)
                else -> null
            }
        }
        return publisher(controls, completeAfterEmission = controls.isEmpty())
    }

    override fun performControlAction(
        controlId: String,
        action: ControlAction,
        consumer: Consumer<Int>
    ) {
        if (action !is CommandAction) {
            consumer.accept(ControlAction.RESPONSE_FAIL)
            return
        }
        val pattern = SmartControlPreferences.getPattern(this, controlId)
        if (pattern.isNullOrBlank()) {
            consumer.accept(ControlAction.RESPONSE_FAIL)
            return
        }
        IrTransmissionEngine.submit(
            this,
            pattern,
            onSuccess = { consumer.accept(ControlAction.RESPONSE_OK) },
            onError = { error ->
                android.util.Log.e("RGBRemoteSmart", "Device Control IR transmission failed", error)
                consumer.accept(ControlAction.RESPONSE_FAIL)
            }
        )
    }

    private fun createAvailableControl(id: String, title: String, requestCode: Int): Control {
        return Control.StatelessBuilder(id, appIntent(requestCode))
            .setTitle(title)
            .setSubtitle("RGB Remote")
            .setDeviceType(DeviceTypes.TYPE_LIGHT)
            .setStructure("RGB Remote")
            .build()
    }

    private fun createActionControl(id: String, title: String, requestCode: Int): Control {
        return Control.StatefulBuilder(id, appIntent(requestCode))
            .setTitle(title)
            .setSubtitle("RGB Remote")
            .setDeviceType(DeviceTypes.TYPE_LIGHT)
            .setStatus(Control.STATUS_OK)
            .setAuthRequired(false)
            .setControlTemplate(StatelessTemplate(id))
            .setStructure("RGB Remote")
            .build()
    }

    private fun appIntent(requestCode: Int): PendingIntent {
        val intent = Intent(this, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun <T> publisher(
        items: List<T>,
        completeAfterEmission: Boolean
    ): Flow.Publisher<T> {
        return Flow.Publisher { subscriber ->
            subscriber.onSubscribe(object : Flow.Subscription {
                private var index = 0
                @Volatile private var cancelled = false

                override fun request(n: Long) {
                    if (cancelled) return
                    if (n <= 0) {
                        cancelled = true
                        subscriber.onError(IllegalArgumentException("Demand must be positive"))
                        return
                    }
                    var remaining = n
                    while (remaining > 0 && index < items.size && !cancelled) {
                        subscriber.onNext(items[index++])
                        remaining--
                    }
                    if (completeAfterEmission && index >= items.size && !cancelled) {
                        cancelled = true
                        subscriber.onComplete()
                    }
                }

                override fun cancel() {
                    cancelled = true
                }
            })
        }
    }
}
