package dev.raone.ahealth

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity(){
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        enqueueWork(this)
    }
}