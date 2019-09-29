//
//  AppDelegate.swift
//  CocoaheadsConf
//
//  Created by Bruno Bilescky on 01/11/16.
//  Copyright © 2016 Cocoaheads. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    lazy var mainScene: MainScene<URLSessionFetcher> = {
        let cache = Cache.default
        let talksScene = TalksScene(cache: cache)
        let speakersScene = SpeakersScene(cache: cache)
        let sponsorsScene = SponsorsScene(cache: cache)
        let videosScene = VideosScene(cache: cache, talksScene: talksScene)
        let eventScene = EventScene(cache: cache)
        return MainScene(with: [eventScene, talksScene, speakersScene, sponsorsScene, videosScene])
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.mainScene.startWithWindow(window: window)
        self.window = window
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
    }
    

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        self.mainScene.fetchNewData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}
