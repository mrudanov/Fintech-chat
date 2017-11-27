//
//  AppDelegate.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 23/09/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIGestureRecognizerDelegate {

    var window: UIWindow?
    
    let rootAssembly = RootAssembly()
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainVC = rootAssembly.conversationsListModule.embededInNavProfileVC()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        rootAssembly.turnOffCommunicator()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        rootAssembly.turnOnCommunicator()
    }
}

