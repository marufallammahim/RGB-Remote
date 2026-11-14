package com.marufallammahim.rgbremote

import android.content.Context
import android.hardware.ConsumerIrManager
import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.RejectedExecutionException
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.TimeUnit

/**
 * Process-wide IR queue shared by the Flutter remote, launcher widget and
 * Android Device Controls. Serializing every transmission prevents competing
 * ConsumerIrManager.transmit() calls.
 */
object IrTransmissionEngine {
    private const val QUEUE_CAPACITY = 24

    private val executor = ThreadPoolExecutor(
        1, 1, 0L, TimeUnit.MILLISECONDS,
        ArrayBlockingQueue<Runnable>(QUEUE_CAPACITY),
        ThreadPoolExecutor.AbortPolicy()
    ).apply {
        allowCoreThreadTimeOut(true)
    }

    @Volatile private var irManager: ConsumerIrManager? = null

    fun initialize(context: Context) {
        if (irManager != null) return
        synchronized(this) {
            if (irManager == null) {
                irManager = context.applicationContext
                    .getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager
            }
        }
    }

    fun execute(operation: () -> Unit) {
        executor.execute(operation)
    }

    fun hasIrEmitter(context: Context): Boolean {
        initialize(context)
        return irManager?.hasIrEmitter() == true
    }

    fun validatePronto(pattern: String) {
        parsePronto(pattern)
    }

    fun transmitPronto(context: Context, pattern: String) {
        initialize(context)
        val manager = irManager ?: throw IllegalStateException("IR service is unavailable")
        if (!manager.hasIrEmitter()) throw IllegalStateException("This device does not have an IR emitter")
        val parsed = parsePronto(pattern)
        manager.transmit(parsed.first, parsed.second)
    }

    fun submit(
        context: Context,
        pattern: String,
        onSuccess: () -> Unit,
        onError: (Exception) -> Unit
    ): Boolean {
        return try {
            execute {
                try {
                    transmitPronto(context, pattern)
                    onSuccess()
                } catch (error: Exception) {
                    onError(error)
                }
            }
            true
        } catch (error: RejectedExecutionException) {
            onError(error)
            false
        }
    }

    private fun parsePronto(data: String): Pair<Int, IntArray> {
        val words = data.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
        require(words.size >= 6) { "Pronto code is incomplete" }
        require(words.all { it.matches(Regex("[0-9A-Fa-f]{1,4}")) }) {
            "Pronto code contains an invalid hexadecimal word"
        }
        require(words[0].equals("0000", ignoreCase = true)) {
            "Only raw Pronto 0000 codes are supported"
        }

        val frequencyWord = words[1].toInt(16)
        val introPairs = words[2].toInt(16)
        val repeatPairs = words[3].toInt(16)
        require(frequencyWord > 0) { "Pronto carrier frequency word must not be zero" }
        val expectedWords = 4L + 2L * (introPairs.toLong() + repeatPairs.toLong())
        require(expectedWords == words.size.toLong()) { "Pronto timing count mismatch" }
        require(introPairs + repeatPairs > 0) { "Pronto command contains no timings" }

        val carrierFrequency = (1_000_000.0 / (frequencyWord * 0.241246)).toInt()
        require(carrierFrequency in 10_000..500_000) {
            "Pronto carrier frequency is outside the supported safety range"
        }
        val pulsePeriodMicros = (1_000_000.0 / carrierFrequency).toInt().coerceAtLeast(1)
        val durations = IntArray(words.size - 4)
        for (index in durations.indices) {
            val count = words[index + 4].toInt(16)
            require(count > 0) { "Pronto timing values must be greater than zero" }
            val duration = count.toLong() * pulsePeriodMicros.toLong()
            require(duration <= Int.MAX_VALUE) { "Pronto timing value is too large" }
            durations[index] = duration.toInt()
        }
        return carrierFrequency to durations
    }
}
