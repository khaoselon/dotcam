package com.mkproject.dotcam

import android.app.Application
import com.google.android.gms.ads.MobileAds

class DotCamApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // Google Mobile Ads 初期化
        MobileAds.initialize(this) { }
        
        // その他の初期化処理
        setupCrashlytics()
    }
    
    private fun setupCrashlytics() {
        // クラッシュレポートの設定
        // Firebase Crashlyticsを使用する場合はここで設定
    }
}