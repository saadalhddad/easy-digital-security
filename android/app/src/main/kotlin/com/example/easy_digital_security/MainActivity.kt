package com.example.easy_digital_security // اسم حزمة مشروعك

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone // استيراد TimeZone

class MainActivity: FlutterActivity() {
    // تعريف اسم القناة. يجب أن يتطابق هذا مع الاسم المستخدم في كود Dart.
    private val CHANNEL = "com.saadonplayer/timezone" // هذا الاسم يجب أن يتطابق تمامًا مع main.dart

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "getTimeZone") {
                val timeZone = TimeZone.getDefault().id // الحصول على معرف المنطقة الزمنية الافتراضية للجهاز
                result.success(timeZone)
            } else {
                result.notImplemented()
            }
        }
    }
}
