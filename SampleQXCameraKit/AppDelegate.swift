//
//  AppDelegate.swift
//  SampleQXCameraKit
//
//  Created by Hirakawa Akira on 14/12/14.
//  Copyright (c) 2014 akirahrkw. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        var controller = CameraViewController()

        var nav = UINavigationController(rootViewController:controller)
        nav.navigationBar.barStyle = UIBarStyle.Black
        nav.view.backgroundColor = UIColor.whiteColor()
        nav.navigationBar.tintColor = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)

        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        self.window = UIWindow(frame:UIScreen.mainScreen().bounds)
        self.window!.rootViewController = nav
        self.window!.makeKeyAndVisible()
        return true
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

