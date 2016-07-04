  //
//  AppDelegate.swift
//  swiftMeiZi
//
//  Created by teddy on 4/5/16.
//  Copyright © 2016 teddy. All rights reserved.
//

import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // 2B3347 - main color
        
        // 添加友盟分享
        UMSocialData.setAppKey(Constants.uMengAppKey)
        UMSocialWechatHandler.setWXAppId("wxdcb864981f096ca2", appSecret: "04c97dd46642feaaaf46aebb650933ed", url: "http://gank.applinzi.com/")
        UMSocialConfig.hiddenNotInstallPlatforms([UMShareToWechatSession, UMShareToWechatTimeline])
        
        // 添加友盟统计
        let uConfig: UMAnalyticsConfig = UMAnalyticsConfig.init()
        MobClick.setCrashReportEnabled(false)
        uConfig.appKey = Constants.uMengAppKey
        MobClick.startWithConfigure(uConfig)
        
        // 添加友盟推送
        let ns:NSDictionary = NSDictionary()
        UMessage.startWithAppkey(Constants.uMengAppKey, launchOptions: ns as [NSObject : AnyObject])
        UMessage.registerForRemoteNotifications()
        UMessage.setLogEnabled(true)
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }
}

