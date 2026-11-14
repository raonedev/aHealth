package dev.raone.ahealth
import io.flutter.embedding.android.FlutterFragmentActivity
import com.istornz.live_activities.LiveActivityManagerHolder
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
     override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        LiveActivityManagerHolder.instance = CustomLiveActivityManager(this)
    }
}