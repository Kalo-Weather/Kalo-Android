package com.kalo.mobile

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.util.SizeF
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object KaloWidgetData {
    const val TEMP = "widget_temp"
    const val FEELS_LIKE = "widget_feels_like"
    const val CONDITION = "widget_condition"
    const val CONDITION_EMOJI = "widget_condition_emoji"
    const val LOCATION = "widget_location"
    const val UNIT = "widget_unit"
    const val HOURLY_JSON = "widget_hourly_json"
    const val DAILY_JSON = "widget_daily_json"
    const val LAST_UPDATED = "widget_last_updated"
    const val IS_DAY = "widget_is_day"
    const val CONFIG_JSON = "widget_config_json"
}

object KaloWidgetRenderer {

    private const val BASELINE_SMALL_WIDTH = 120
    private const val BASELINE_MEDIUM_WIDTH = 260
    private const val BASELINE_LARGE_WIDTH = 280
    private const val MIN_SCALE = 0.7f
    private const val MAX_SCALE = 1.5f

    private fun getScaleFactor(appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, baselineWidth: Int): Float {
        if (appWidgetIds.isEmpty()) return 1.0f
        val opts = appWidgetManager.getAppWidgetOptions(appWidgetIds[0])
        val actualWidth = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val sizes = opts.getParcelableArrayList(AppWidgetManager.OPTION_APPWIDGET_SIZES, SizeF::class.java)
            if (!sizes.isNullOrEmpty()) sizes[0].width.toInt() else baselineWidth
        } else {
            val minW = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, baselineWidth)
            val maxW = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, baselineWidth)
            (minW + maxW) / 2
        }
        return (actualWidth.toFloat() / baselineWidth).coerceIn(MIN_SCALE, MAX_SCALE)
    }

    fun renderSmall(
        context: Context,
        data: SharedPreferences,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val views = RemoteViews(context.packageName, R.layout.kalo_widget_small)
        val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.widget_container_small, launchIntent)
        val scale = getScaleFactor(appWidgetManager, appWidgetIds, BASELINE_SMALL_WIDTH)
        applyConfig(context, views, data, "small", scale)
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    fun renderMedium(
        context: Context,
        data: SharedPreferences,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val views = RemoteViews(context.packageName, R.layout.kalo_widget_medium)
        val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.widget_container_medium, launchIntent)
        val scale = getScaleFactor(appWidgetManager, appWidgetIds, BASELINE_MEDIUM_WIDTH)
        applyConfig(context, views, data, "medium", scale)
        applyHourlyData(context, views, data, scale)
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    fun renderLarge(
        context: Context,
        data: SharedPreferences,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val views = RemoteViews(context.packageName, R.layout.kalo_widget_large)
        val launchIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
        views.setOnClickPendingIntent(R.id.widget_container_large, launchIntent)
        val scale = getScaleFactor(appWidgetManager, appWidgetIds, BASELINE_LARGE_WIDTH)
        applyConfig(context, views, data, "large", scale)
        applyHourlyData(context, views, data, scale)
        appWidgetIds.forEach { id ->
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun setSp(views: RemoteViews, viewId: Int, sp: Float, scale: Float) {
        views.setFloat(viewId, "setTextSize", sp * scale)
    }

    private fun applyConfig(context: Context, views: RemoteViews, data: SharedPreferences, sizeKey: String, scale: Float) {
        val configJson = data.getString(KaloWidgetData.CONFIG_JSON, null)
        val blocks = if (configJson != null) {
            parseBlockOrder(configJson, sizeKey)
        } else {
            defaultBlocks(sizeKey)
        }

        val temp = data.getString(KaloWidgetData.TEMP, null) ?: "--°"
        val emoji = data.getString(KaloWidgetData.CONDITION_EMOJI, null) ?: "\u2601\uFE0F"
        val location = data.getString(KaloWidgetData.LOCATION, null) ?: "My Location"
        val feelsLike = data.getString(KaloWidgetData.FEELS_LIKE, null)
        val lastUpdated = data.getString(KaloWidgetData.LAST_UPDATED, null)

        val visibleBlocks = mutableListOf<String>()

        val tempSize = if (sizeKey == "small") 36f else if (sizeKey == "medium") 38f else 34f
        val emojiSize = if (sizeKey == "small") 28f else 26f
        val primarySize = if (sizeKey == "small") 11f else if (sizeKey == "medium") 12f else 12f
        val secondarySize = 11f
        val blockSize = 11f

        for (block in blocks) {
            val id = blockIdFor(context, block)
            if (id != null) {
                when (block) {
                    "temperature" -> {
                        views.setTextViewText(id, temp)
                        setSp(views, id, tempSize, scale)
                        visibleBlocks.add(block)
                    }
                    "conditionIcon" -> {
                        views.setTextViewText(id, emoji)
                        setSp(views, id, emojiSize, scale)
                        visibleBlocks.add(block)
                    }
                    "locationName" -> {
                        views.setTextViewText(id, location)
                        setSp(views, id, primarySize, scale)
                        visibleBlocks.add(block)
                    }
                    "condition" -> {
                        val c = data.getString(KaloWidgetData.CONDITION, null) ?: ""
                        views.setTextViewText(id, c)
                        setSp(views, id, secondarySize, scale)
                        visibleBlocks.add(block)
                    }
                        "feelsLike" -> {
                        if (feelsLike != null) {
                            views.setTextViewText(id, "Feels like $feelsLike")
                            setSp(views, id, secondarySize, scale)
                            visibleBlocks.add(block)
                        }
                    }
                    "time" -> {
                        if (lastUpdated != null) {
                            val time = formatTime(lastUpdated)
                            views.setTextViewText(id, "Updated $time")
                            setSp(views, id, secondarySize, scale)
                            visibleBlocks.add(block)
                        }
                    }
                    "humidity" -> {
                        val h = data.getString("widget_humidity", null) ?: "--%"
                        views.setTextViewText(id, "\uD83D\uDCA7 $h")
                        setSp(views, id, blockSize, scale)
                        visibleBlocks.add(block)
                    }
                    "wind" -> {
                        val w = data.getString("widget_wind", null) ?: "--"
                        views.setTextViewText(id, "\uD83C\uDF2C\uFE0F $w")
                        setSp(views, id, blockSize, scale)
                        visibleBlocks.add(block)
                    }
                    "uvIndex" -> {
                        val u = data.getString("widget_uv", null) ?: "--"
                        views.setTextViewText(id, "\u2600\uFE0F UV $u")
                        setSp(views, id, blockSize, scale)
                        visibleBlocks.add(block)
                    }
                    "aqi" -> {
                        val a = data.getString("widget_aqi", null) ?: "--"
                        views.setTextViewText(id, "\uD83C\uDF2B\uFE0F AQI $a")
                        setSp(views, id, blockSize, scale)
                        visibleBlocks.add(block)
                    }
                }
            }
        }

        val allBlockIds = allBlockIdsFor(sizeKey)
        for (bid in allBlockIds) {
            val blockType = blockTypeForId(context, bid)
            if (blockType != null && blockType !in visibleBlocks) {
                views.setViewVisibility(bid, View.GONE)
            }
        }
    }

    private fun parseBlockOrder(configJson: String, sizeKey: String): List<String> {
        return try {
            val root = JSONObject(configJson)
            val sizes = root.getJSONObject("sizes")
            if (sizes.has(sizeKey)) {
                val config = sizes.getJSONObject(sizeKey)
                val arr = config.getJSONArray("blocks")
                (0 until arr.length()).map { arr.getString(it) }
            } else {
                defaultBlocks(sizeKey)
            }
        } catch (_: Exception) {
            defaultBlocks(sizeKey)
        }
    }

    private fun defaultBlocks(sizeKey: String): List<String> {
        return when (sizeKey) {
            "small" -> listOf("locationName", "temperature", "conditionIcon", "condition")
            "medium" -> listOf("locationName", "temperature", "conditionIcon", "feelsLike")
            "large" -> listOf("locationName", "temperature", "conditionIcon", "feelsLike", "humidity", "wind", "uvIndex", "aqi")
            else -> listOf("temperature", "conditionIcon")
        }
    }

    private fun blockIdFor(context: Context, block: String): Int? {
        return when (block) {
            "temperature" -> R.id.widget_temp
            "conditionIcon" -> R.id.widget_condition_emoji
            "condition" -> R.id.widget_condition
            "locationName" -> R.id.widget_location
            "feelsLike" -> R.id.widget_feels_like
            "time" -> R.id.widget_time
            "humidity" -> R.id.widget_humidity
            "wind" -> R.id.widget_wind
            "uvIndex" -> R.id.widget_uv
            "aqi" -> R.id.widget_aqi
            else -> null
        }
    }

    private fun blockTypeForId(context: Context, id: Int): String? {
        return when (id) {
            R.id.widget_temp -> "temperature"
            R.id.widget_condition_emoji -> "conditionIcon"
            R.id.widget_condition -> "condition"
            R.id.widget_location -> "locationName"
            R.id.widget_feels_like -> "feelsLike"
            R.id.widget_time -> "time"
            R.id.widget_humidity -> "humidity"
            R.id.widget_wind -> "wind"
            R.id.widget_uv -> "uvIndex"
            R.id.widget_aqi -> "aqi"
            else -> null
        }
    }

    private fun allBlockIdsFor(sizeKey: String): List<Int> {
        return when (sizeKey) {
            "small" -> listOf(R.id.widget_temp, R.id.widget_condition_emoji, R.id.widget_condition, R.id.widget_location)
            "medium" -> listOf(R.id.widget_temp, R.id.widget_condition_emoji, R.id.widget_location, R.id.widget_feels_like, R.id.widget_time)
            "large" -> listOf(
                R.id.widget_temp, R.id.widget_condition_emoji, R.id.widget_location,
                R.id.widget_feels_like, R.id.widget_time, R.id.widget_humidity,
                R.id.widget_wind, R.id.widget_uv, R.id.widget_aqi
            )
            else -> emptyList()
        }
    }

    private fun applyHourlyData(context: Context, views: RemoteViews, data: SharedPreferences, scale: Float) {
        val hourlyJson = data.getString(KaloWidgetData.HOURLY_JSON, null) ?: return
        try {
            val arr = JSONArray(hourlyJson)
            val timeFormat = SimpleDateFormat("ha", Locale.getDefault())
            val count = minOf(arr.length(), 5)

            val hourlyIds = intArrayOf(
                R.id.hourly_0, R.id.hourly_1, R.id.hourly_2, R.id.hourly_3, R.id.hourly_4
            )
            val hourlyTextSize = 10f * scale

            for (i in 0 until count) {
                val item = arr.getJSONObject(i)
                val ts = item.getLong("time") * 1000L
                val hourLabel = timeFormat.format(Date(ts))
                    .lowercase(Locale.getDefault())
                    .replace("am", "a")
                    .replace("pm", "p")
                val tempC = item.getDouble("temp")
                val code = item.getInt("code")
                val emoji = wmoCodeToEmoji(code)
                val temp = formatTemp(tempC, data)
                views.setTextViewText(hourlyIds[i], "$hourLabel\n$emoji\n$temp")
                views.setFloat(hourlyIds[i], "setTextSize", hourlyTextSize)
            }

            for (i in count until 5) {
                views.setViewVisibility(hourlyIds[i], View.GONE)
            }
        } catch (_: Exception) { }
    }

    private fun formatTemp(celsius: Double, data: SharedPreferences): String {
        val unit = data.getString(KaloWidgetData.UNIT, null) ?: "C"
        val temp = if (unit == "F") celsius * 9.0 / 5.0 + 32.0 else celsius
        return "${temp.toInt()}°"
    }

    private fun formatTime(iso: String): String {
        return try {
            val sdf = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.getDefault())
            val date = sdf.parse(iso.take(19))
            val out = SimpleDateFormat("h:mm a", Locale.getDefault())
            out.format(date!!)
                .lowercase(Locale.getDefault())
                .replace("am", "am")
                .replace("pm", "pm")
        } catch (_: Exception) {
            ""
        }
    }

    private fun wmoCodeToEmoji(code: Int): String {
        return when (code) {
            0 -> "\u2600\uFE0F"
            1, 2 -> "\u26C5"
            3 -> "\u2601\uFE0F"
            45, 48 -> "\uD83C\uDF2B\uFE0F"
            51, 53, 55, 56, 57 -> "\uD83C\uDF27\uFE0F"
            61, 63, 65, 66, 67, 80, 81, 82 -> "\uD83C\uDF27\uFE0F"
            71, 73, 75, 77, 85, 86 -> "\u2744\uFE0F"
            95, 96, 99 -> "\u26C8\uFE0F"
            else -> "\u2601\uFE0F"
        }
    }
}

class KaloWidgetSmallProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        KaloWidgetRenderer.renderSmall(context, widgetData, appWidgetManager, appWidgetIds)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle?,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), getPrefs(context))
    }

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences("home_widget_preferences", Context.MODE_PRIVATE)
    }
}

class KaloWidgetMediumProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        KaloWidgetRenderer.renderMedium(context, widgetData, appWidgetManager, appWidgetIds)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle?,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), getPrefs(context))
    }

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences("home_widget_preferences", Context.MODE_PRIVATE)
    }
}

class KaloWidgetLargeProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        KaloWidgetRenderer.renderLarge(context, widgetData, appWidgetManager, appWidgetIds)
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: android.os.Bundle?,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), getPrefs(context))
    }

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences("home_widget_preferences", Context.MODE_PRIVATE)
    }
}
