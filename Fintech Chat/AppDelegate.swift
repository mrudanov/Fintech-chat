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
    
    let generator: IconGenerator = TinkoffIconsGenerator()
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainVC = rootAssembly.conversationsListModule.embededInNavProfileVC()
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        
        generator.setTarget(view: window)
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        rootAssembly.turnOffCommunicator()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        rootAssembly.turnOnCommunicator()
    }
    
    // MARK: - Icon generating
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            generator.startGenerating(from: firstTouch.location(in: window))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            generator.setGeneratePosition(firstTouch.location(in: window))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        generator.stopGenerating()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        generator.stopGenerating()
    }
}

