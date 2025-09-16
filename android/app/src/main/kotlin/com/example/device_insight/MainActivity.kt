package com.example.device_insight

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.media.AudioManager
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "device_info_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceName" -> {
                    val deviceName = getDeviceName()
                    result.success(deviceName)
                }
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    result.success(batteryLevel)
                }
                "getScreenBrightness" -> {
                    val brightness = getScreenBrightness()
                    result.success(brightness)
                }
                "getAudioVolume" -> {
                    val volume = getAudioVolume()
                    result.success(volume)
                }
                "getInstalledApps" -> {
                    val apps = getInstalledApps()
                    result.success(apps)
                }
                "openApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        val success = openApp(packageName)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Package name is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getDeviceName(): String {
        return Settings.Global.getString(contentResolver, "device_name")
            ?: "${Build.MANUFACTURER} ${Build.MODEL}"
        /*return try{
            val manufacturer = Build.MANUFACTURER
            val model = Build.MODEL

            if (model.lowercase().startsWith(manufacturer.lowercase())) {
                model.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
            } else {
                "${manufacturer.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }} $model"
            }
        }catch (e: Exception){
            Log.e("MainActivity", "Lỗi khi lấy tên thiết bị: ${e.message}")
            "Unknown Device"
        }*/
    }

    private fun getBatteryLevel(): Int {
        val batteryIntent = registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val level = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        return if (level == -1 || scale == -1) 0 else (level * 100 / scale.toFloat()).toInt()
    }

    private fun getScreenBrightness(): Int {
        return try {
            val brightness = Settings.System.getInt(
                contentResolver,
                Settings.System.SCREEN_BRIGHTNESS
            )
            (brightness * 100 / 255.0f).toInt()
        } catch (e: Settings.SettingNotFoundException) {
            0
        }
    }

    private fun getAudioVolume(): Int {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val currentVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        return if (maxVolume == 0) 0 else (currentVolume * 100 / maxVolume)
    }

    private fun getInstalledApps(): List<Map<String, Any>> {
        val packageManager = packageManager
        val apps = mutableListOf<Map<String, Any>>()

        // Get apps that have launcher intent (visible in launcher)
        val mainIntent = Intent(Intent.ACTION_MAIN, null)
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER)
        val pkgAppsList = packageManager.queryIntentActivities(mainIntent, 0)

        val usageStats = getUsageStats()

        for (resolveInfo in pkgAppsList) {
            val packageName = resolveInfo.activityInfo.packageName

            try {
                val applicationInfo = packageManager.getApplicationInfo(packageName, 0)

                // Skip system apps that are not user apps
                if (applicationInfo.flags and ApplicationInfo.FLAG_SYSTEM != 0 &&
                    applicationInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP == 0) {
                    continue
                }

                val appName = packageManager.getApplicationLabel(applicationInfo).toString()
                val icon = packageManager.getApplicationIcon(applicationInfo)
                val iconBytes = drawableToByteArray(icon)
                val usageTime = usageStats[packageName] ?: 0L

                val appInfo = mapOf(
                    "name" to appName,
                    "packageName" to packageName,
                    "icon" to iconBytes,
                    "usageTime" to usageTime
                )
                apps.add(appInfo)
            } catch (e: PackageManager.NameNotFoundException) {
                // Skip if app not found
                continue
            }
        }

        // Sort by app name
        return apps.sortedByDescending { it["usageTime"] as Long }
    }

    private fun getUsageStats(): Map<String, Long> {
        val usageStatsMap = mutableMapOf<String, Long>()

        if (!hasUsageStatsPermission()) {
            return usageStatsMap
        }

        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return usageStatsMap

        val cal = Calendar.getInstance()
        cal.set(Calendar.HOUR_OF_DAY, 0)
        cal.set(Calendar.MINUTE, 0)
        cal.set(Calendar.SECOND, 0)
        cal.set(Calendar.MILLISECOND, 0)
        val startTime = cal.timeInMillis
        val endTime = System.currentTimeMillis()

        try {
            val stats = usageStatsManager.queryUsageStats(
                UsageStatsManager.INTERVAL_DAILY, startTime, endTime
            )

            for (usageStats in stats) {
                if (usageStats.totalTimeInForeground > 0) {
                    val existing = usageStatsMap[usageStats.packageName] ?: 0L
                    usageStatsMap[usageStats.packageName] = existing + usageStats.totalTimeInForeground
                }
            }
        } catch (e: Exception) {
            // Handle exception if usage stats access fails
        }

        return usageStatsMap
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOpsManager = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOpsManager.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        } else {
            @Suppress("DEPRECATION")
            appOpsManager.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val bitmap = Bitmap.createBitmap(
                drawable.intrinsicWidth,
                drawable.intrinsicHeight,
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bitmap)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bitmap
        }

        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }

    private fun openApp(packageName: String): Boolean {
        return try {
            val intent = packageManager.getLaunchIntentForPackage(packageName)
            if (intent != null) {
                startActivity(intent)
                true
            } else {
                false
            }
        } catch (e: Exception) {
            false
        }
    }
}
