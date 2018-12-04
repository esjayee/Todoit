//
//  AppDelegate.swift
//  Todoit
//
//  Created by Susan Emmons on 20/11/2018.
//  Copyright © 2018 Susan Emmons. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        do {
            _ = try Realm()
        } catch {
            print("Unable to initialise new realm database \(error)")
        }
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }

}

