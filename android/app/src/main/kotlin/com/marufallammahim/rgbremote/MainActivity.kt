package com.marufallammahim.rgbremote

import android.content.Context
import android.hardware.ConsumerIrManager
import android.media.AudioAttributes
import android.media.SoundPool
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ThreadPoolExecutor
import java.util.concurrent.ArrayBlockingQueue
import java.util.concurrent.TimeUnit
import java.util.concurrent.RejectedExecutionException


class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var irManager: ConsumerIrManager? = null
    @Volatile
    private var frequency = 38028 // 38KHz

    // ConsumerIrManager.transmit() may take noticeable time. Keep it away from
    // Flutter's platform/UI thread and serialize quick repeated button presses.
    // A bounded queue prevents unbounded memory growth when a user taps rapidly.
    // When saturated, a clear error is returned rather than crashing the app.
    private val irExecutor = ThreadPoolExecutor(
        1, 1, 0L, TimeUnit.MILLISECONDS,
        ArrayBlockingQueue<Runnable>(24),
        ThreadPoolExecutor.AbortPolicy()
    )
    @Volatile private var activityDestroyed = false
    private val mainHandler = Handler(Looper.getMainLooper())

    private lateinit var attributes: AudioAttributes
    private lateinit var vibrator: Vibrator
    private lateinit var soundPool: SoundPool

    private val soundMap = mutableMapOf<String, Int>()
    private val loadedSoundIds = mutableSetOf<Int>()

    private fun loadAllSounds() {
        val fields = R.raw::class.java.fields
        fields.forEach { field ->
            try {
                val name = field.name
                val resourceId = field.getInt(null)
                val soundId = soundPool.load(context, resourceId, 1)
                soundMap[name] = soundId
            } catch (exception: Exception) {
                android.util.Log.w("RGBRemote", "Unable to load sound resource", exception)
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ir_sensor_plugin")
        channel.setMethodCallHandler(this)

        attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()

        vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager =
                getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
            vibratorManager.defaultVibrator
        } else {
            @Suppress("deprecation")
            getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        }

        soundPool = SoundPool.Builder()
            .setMaxStreams(1)
            .setAudioAttributes(attributes)
            .build()
        soundPool.setOnLoadCompleteListener { _, sampleId, status ->
            synchronized(loadedSoundIds) {
                if (status == 0) loadedSoundIds.add(sampleId)
                else loadedSoundIds.remove(sampleId)
            }
        }

        irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

        loadAllSounds()
    }

    override fun onKeyDown(keyCode: Int, event: android.view.KeyEvent): Boolean {
        if (event.repeatCount == 0 &&
            (keyCode == android.view.KeyEvent.KEYCODE_VOLUME_UP ||
             keyCode == android.view.KeyEvent.KEYCODE_VOLUME_DOWN)) {
            val direction = if (keyCode == android.view.KeyEvent.KEYCODE_VOLUME_UP) "up" else "down"
            if (::channel.isInitialized && !activityDestroyed) {
                channel.invokeMethod("hardwareVolumeKey", mapOf("direction" to direction))
            }
            // Keep Android's media volume unchanged while this remote is open.
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onKeyUp(keyCode: Int, event: android.view.KeyEvent): Boolean {
        if (keyCode == android.view.KeyEvent.KEYCODE_VOLUME_UP ||
            keyCode == android.view.KeyEvent.KEYCODE_VOLUME_DOWN) return true
        return super.onKeyUp(keyCode, event)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasIrEmitter" -> hasIrEmitter(result)
            "codeForEmitter" -> transmitString(call, result)
            "setFrequency" -> setFrequency(call, result)
            "transmitListInt" -> transmitList(call, result)
            "getCarrierFrequencies" -> getCarrierFrequencies(result)
            "vibrate" -> vibrate(result)
            "rawSoundList" -> rawSoundList(result)
            "playSound" -> playSound(call, result)
            else -> result.notImplemented()
        }
    }

    /**
     * This method convert the Count Pattern to Duration Pattern by multiplying each value by the pulses
     *
     * @param data String in hex code.
     * @return a int Array with all of the Duration values.
     * @see [This method was created by Randy](http://stackoverflow.com/users/1679571/randy)>
     */
    private data class ParsedPronto(val carrierFrequency: Int, val durations: IntArray)

    /** Parse and validate a standard raw Pronto Hex (0000) command. */
    private fun parsePronto(data: String): ParsedPronto {
        val words = data.trim().split(Regex("\\s+")).filter { it.isNotEmpty() }
        if (words.size < 6) {
            throw IllegalArgumentException("Pronto code is incomplete: expected at least 6 hexadecimal words")
        }
        if (!words.all { it.matches(Regex("[0-9A-Fa-f]{1,4}")) }) {
            throw IllegalArgumentException("Pronto code contains an invalid hexadecimal word")
        }
        if (!words[0].equals("0000", ignoreCase = true)) {
            throw IllegalArgumentException("Unsupported Pronto format ${words[0]}; only raw 0000 codes are supported")
        }

        val frequencyWord = words[1].toInt(16)
        val introPairs = words[2].toInt(16)
        val repeatPairs = words[3].toInt(16)
        if (frequencyWord == 0) throw IllegalArgumentException("Pronto carrier frequency word must not be zero")
        val expectedWords = 4L + 2L * (introPairs.toLong() + repeatPairs.toLong())
        if (expectedWords != words.size.toLong()) {
            throw IllegalArgumentException("Pronto timing count mismatch: header expects $expectedWords words, got ${words.size}")
        }
        if (introPairs + repeatPairs <= 0) throw IllegalArgumentException("Pronto command contains no timings")

        val carrierFrequency = (1_000_000.0 / (frequencyWord * 0.241246)).toInt()
        if (carrierFrequency !in 10_000..500_000) {
            throw IllegalArgumentException("Pronto carrier frequency is outside the supported safety range")
        }
        val pulsePeriodMicros = (1_000_000.0 / carrierFrequency).toInt().coerceAtLeast(1)
        val durations = IntArray(words.size - 4)
        for (index in durations.indices) {
            val count = words[index + 4].toInt(16)
            if (count <= 0) throw IllegalArgumentException("Pronto timing values must be greater than zero")
            val duration = count.toLong() * pulsePeriodMicros.toLong()
            if (duration > Int.MAX_VALUE) throw IllegalArgumentException("Pronto timing value is too large")
            durations[index] = duration.toInt()
        }
        return ParsedPronto(carrierFrequency, durations)
    }

    /**
     * Transmit an infrared pattern,
     *
     * @param result return a String "Emitting" if there was no problem in the process.
     */
    private fun enqueueIr(result: MethodChannel.Result, operation: () -> Unit) {
        try {
            irExecutor.execute {
                try {
                    operation()
                    mainHandler.post {
                        if (!activityDestroyed) result.success("Success")
                    }
                } catch (exception: Exception) {
                    mainHandler.post {
                        if (!activityDestroyed) {
                            result.error("2", exception.message ?: "IR transmission failed", exception.message)
                        }
                    }
                }
            }
        } catch (exception: RejectedExecutionException) {
            mainHandler.post {
                if (!activityDestroyed) {
                    result.error("BUSY", "IR queue is full or shutting down. Please wait briefly.", null)
                }
            }
        }
    }

    private fun transmitString(call: MethodCall, result: MethodChannel.Result) {
        val pattern = call.argument<String>("codeForEmitter")
        if (pattern.isNullOrBlank()) {
            result.error("2", "Unexpected or empty parameter: codeForEmitter", null)
            return
        }

        if (!hasIrEmitter()) {
            result.error("1", "Device doesn't support IR", null)
            return
        }

        val manager = irManager
        if (manager == null) {
            result.error("1", "IR service is unavailable", null)
            return
        }

        enqueueIr(result) {
            // The Pronto header contains the intended carrier; use it for this command.
            val parsed = parsePronto(pattern)
            manager.transmit(parsed.carrierFrequency, parsed.durations)
        }
    }

    private fun transmitList(call: MethodCall, result: MethodChannel.Result) {
        val listInt = call.argument<List<Int>>("transmitListInt")
        if (listInt == null) {
            result.error("2", "Unexpected null parameter: transmitListInt", null)
            return
        }

        if (listInt.isEmpty() || listInt.any { it <= 0 }) {
            result.error("2", "transmitListInt must contain positive timing values", null)
            return
        }

        if (!hasIrEmitter()) {
            result.error("1", "Device doesn't support IR", null)
            return
        }

        val manager = irManager
        if (manager == null) {
            result.error("1", "IR service is unavailable", null)
            return
        }

        val timings = listInt.toIntArray()
        val transmitFrequency = frequency
        enqueueIr(result) {
            manager.transmit(transmitFrequency, timings)
        }
    }

    /**
     * Check whether the device has an infrared emitter.
     *
     * @return "true" if the device has an infrared emitter, else "false" .
     */
    private fun hasIrEmitter(result: MethodChannel.Result) {
        result.success(hasIrEmitter())
    }

    /**
     * Change the frequency with which it is transmitted
     */
    private fun setFrequency(call: MethodCall, result: MethodChannel.Result) {
        val newFrequency = call.argument<Int>("setFrequency")
        if (newFrequency == null) {
            result.error("2", "Unexpected null parameter: newFrequency", null)
            return
        }

        if (newFrequency !in 10_000..500_000) {
            result.error("2", "Frequency must be between 10000 and 500000 Hz", null)
            return
        }
        this.frequency = newFrequency
        result.success("Success")
    }

    /**
     * Query the infrared transmitter's supported carrier frequencies in `Hertz`.
     */
    private fun getCarrierFrequencies(result: MethodChannel.Result) {
        if (!hasIrEmitter()) {
            result.error("1", "Device doesn't support IR", null)
            return
        }

        val manager = irManager
        if (manager == null) {
            result.error("1", "IR service is unavailable", null)
            return
        }
        val stringBuilder = StringBuilder()
        val freq = manager.carrierFrequencies
        for (range in freq) {
            stringBuilder.append("${range.minFrequency} - ${range.maxFrequency}")
            stringBuilder.append("\n")
        }
        result.success(stringBuilder.toString())
    }

    /**
     * Make a soft vibration effect
     */
    private fun vibrate(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val vibrationEffect = VibrationEffect.createOneShot(10L, VibrationEffect.DEFAULT_AMPLITUDE)
            vibrator.vibrate(vibrationEffect, attributes)
        } else {
            vibrator.vibrate(10L)
        }
        result.success(null)
    }

    /**
     * Return the list of files in raw folder
     */
    private fun rawSoundList(result: MethodChannel.Result) {
        if (soundMap.isEmpty()) {
            result.error("1", "No sounds are available", null)
            return
        }

        result.success(soundMap)
    }

    /**
     * Play a tap sound
     */
    private fun playSound(call: MethodCall, result: MethodChannel.Result) {
        if (soundMap.isEmpty()) {
            result.error("NO_SOUNDS", "No sound resources are available", null)
            return
        }
        val soundName = call.argument<String>("soundName")
        val soundId = soundMap[soundName] ?: soundMap.values.first()
        val isLoaded = synchronized(loadedSoundIds) { loadedSoundIds.contains(soundId) }
        if (isLoaded) {
            val streamId = soundPool.play(soundId, 1f, 1f, 1, 0, 1f)
            if (streamId == 0) android.util.Log.d("RGBRemote", "SoundPool could not start sound yet")
        }
        // Sound is optional feedback; do not fail remote transmission while it loads.
        result.success(null)
    }

    private fun hasIrEmitter(): Boolean {
        return irManager?.hasIrEmitter() == true
    }

    override fun onDestroy() {
        activityDestroyed = true
        if (!irExecutor.isShutdown) irExecutor.shutdownNow()
        super.onDestroy()
    }

    override fun detachFromFlutterEngine() {
        if (::channel.isInitialized) channel.setMethodCallHandler(null)
        if (::soundPool.isInitialized) soundPool.release()
        super.detachFromFlutterEngine()
    }
}
