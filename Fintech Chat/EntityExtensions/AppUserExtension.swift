//
//  File.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 06/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import CoreData


extension AppUser {
    static func findOrInsertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var appUser: AppUser?
        guard let fetchRequest = AppUser.fetchRequestAppUser(model: model) else {
            return nil
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            if let foundUser = results.first {
                appUser = foundUser
            }
        } catch {
            print("Failed to fetch AppUser: \(error)")
        }
        
        if appUser == nil {
            appUser = AppUser.insertAppUser(in: context)
        }
        
        return appUser
    }
    
    static func findAppUser(in context: NSManagedObjectContext) -> AppUser? {
        guard let model = context.persistentStoreCoordinator?.managedObjectModel else {
            print("Model is not available in context!")
            assert(false)
            return nil
        }
        
        var appUser: AppUser?
        guard let fetchRequest = AppUser.fetchRequestAppUser(model: model) else {
            return nil
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            if let foundUser = results.first {
                appUser = foundUser
            }
        } catch {
            print("Failed to fetch AppUser: \(error)")
        }
        
        return appUser
    }
    
    static func insertAppUser(in context: NSManagedObjectContext) -> AppUser? {
        if let appUser = NSEntityDescription.insertNewObject(forEntityName: "AppUser", into: context) as? AppUser {
            if appUser.currentUser == nil {
                let currentUser = User.findOrInsertUser(with: User.generateUserIdString(), in: context)
                currentUser?.name = User.generateCurrentUserNameString()
                appUser.currentUser = currentUser
            }
            return appUser
        }
        return nil
    }
    
    static func fetchRequestAppUser(model: NSManagedObjectModel) -> NSFetchRequest<AppUser>? {
        let templateName = "AppUser"
        guard let fetchRequest = model.fetchRequestTemplate(forName: templateName) as? NSFetchRequest<AppUser> else {
            assert(false, "No template with name \(templateName)!")
            return nil
        }
        return fetchRequest
    }
}
