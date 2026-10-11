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
import java.util.concurrent.Executors


class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel
    private var irManager: ConsumerIrManager? = null
    @Volatile
    private var frequency = 38028 // 38KHz

    // ConsumerIrManager.transmit() may take noticeable time. Keep it away from
    // Flutter's platform/UI thread and serialize quick repeated button presses.
    private val irExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    private lateinit var attributes: AudioAttributes
    private lateinit var vibrator: Vibrator
    private lateinit var soundPool: SoundPool

    private val soundMap = mutableMapOf<String, Int>()

    private fun loadAllSounds() {
        val fields= R.raw::class.java.fields
        fields.forEach {field ->
            val name = field.name
            val resourceId = field.getInt(field)

            val soundId = soundPool.load(context, resourceId, 1)
            soundMap[name] = soundId
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

        irManager = getSystemService(Context.CONSUMER_IR_SERVICE) as? ConsumerIrManager

        loadAllSounds()
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
    private fun hex2dec(data: String): IntArray {
        val list = data.split(" ").toMutableList()
        list.removeAt(0)
        var frequency = list.removeAt(0).toInt(16)
        list.removeAt(0)
        list.removeAt(0)

        frequency = (1000000 / (frequency * 0.241246)).toInt()
        val pulses = 1000000 / frequency

        val pattern = IntArray(list.size)
        for (i in list.indices) {
            val count = list[i].toInt(16)
            pattern[i] = count * pulses
        }
        return pattern
    }

    /**
     * Transmit an infrared pattern,
     *
     * @param result return a String "Emitting" if there was no problem in the process.
     */
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

        val transmitFrequency = frequency
        irExecutor.execute {
            try {
                val durations = hex2dec(pattern)
                manager.transmit(transmitFrequency, durations)
                mainHandler.post { result.success("Success") }
            } catch (exception: Exception) {
                mainHandler.post {
                    result.error("2", "IR transmission failed", exception.message)
                }
            }
        }
    }

    private fun transmitList(call: MethodCall, result: MethodChannel.Result) {
        val listInt = call.argument<List<Int>>("transmitListInt")
        if (listInt == null) {
            result.error("2", "Unexpected null parameter: transmitListInt", null)
            return
        }

        if (listInt.isEmpty()) {
            result.error("2", "transmitListInt must not be empty", null)
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
        irExecutor.execute {
            try {
                manager.transmit(transmitFrequency, timings)
                mainHandler.post { result.success("Success") }
            } catch (exception: Exception) {
                mainHandler.post {
                    result.error("2", "IR transmission failed", exception.message)
                }
            }
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
        if (soundMap.isNotEmpty()) {
            val soundName = call.argument<String>("soundName")
            val soundId = soundMap[soundName] ?: soundMap.values.first()
            soundPool.play(soundId, 1f, 1f, 1, 0, 1f)
        }

        result.success(null)
    }

    private fun hasIrEmitter(): Boolean {
        return irManager?.hasIrEmitter() == true
    }

    override fun onDestroy() {
        irExecutor.shutdown()
        super.onDestroy()
    }

    override fun detachFromFlutterEngine() {
        channel.setMethodCallHandler(null)
        soundPool.release()
        super.detachFromFlutterEngine()
    }
}
