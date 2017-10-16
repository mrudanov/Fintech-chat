//
//  AppDelegate.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 23/09/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let userDataFileName = "UserInfo.txt"

    // variable to store current application state
    var appState = UIApplicationState(rawValue: 1)!
    // dictionary to convert UIApplicationState to String
    let possibleStates: [UIApplicationState: String] = [.active: "active", .inactive: "inactive", .background: "background"]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        printAppState(from: #function)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        printAppState(from: #function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        printAppState(from: #function)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        printAppState(from: #function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        printAppState(from: #function)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        printAppState(from: #function)
    }
    
    // MARK: - Print app state
    
    func printAppState(from function: String) {
        // Get new state
        let newState: UIApplicationState = UIApplication.shared.applicationState
        print("Application moved from \(possibleStates[appState]!) to \(possibleStates[newState]!) state: \(function)")
        
        // Save current state
        appState = newState
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Fintech_Chat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

