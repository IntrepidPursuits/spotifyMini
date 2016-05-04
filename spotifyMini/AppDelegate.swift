//
//  AppDelegate.swift
//  spotifyMini
//
//  Created by Tom O'Malley on 5/4/16.
//  Copyright © 2016 intrepid. All rights reserved.
//

import UIKit

let SpotifySessionUserDefaultsKey = "SpotifySession"
let AppReturnedFromSpotifyNotification = "AppReturnedFromSpotify"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let clientID = "7106e0a1f4c94c6e9e3f1b209e11a3fb"
    let callbackURL = NSURL(string: "intrepid-tom-spotify://callback")!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.setupSpotifyAuth()
        return true
    }
    
    func setupSpotifyAuth() {
        let auth = SPTAuth.defaultInstance()
        auth.clientID = self.clientID
        auth.redirectURL = self.callbackURL
        auth.sessionUserDefaultsKey = SpotifySessionUserDefaultsKey
        auth.requestedScopes = [SPTAuthStreamingScope]
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if SPTAuth.defaultInstance().canHandleURL(url) {
            SPTAuth.defaultInstance().handleAuthCallbackWithTriggeredAuthURL(url, callback: { error, session in
                if let error = error {
                    // FIXME: throw application error
                    NSNotificationCenter.defaultCenter().postNotificationName(AppReturnedFromSpotifyNotification, object: nil, userInfo: ["error":error])
                    return
                }
                NSNotificationCenter.defaultCenter().postNotificationName(AppReturnedFromSpotifyNotification, object: nil, userInfo: ["session":session])
            })
            return true
        }
        return false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
