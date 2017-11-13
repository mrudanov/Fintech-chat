//
//  MessageExtension.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 12/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

import Foundation
import CoreData
import UIKit


extension Message {
    
    static func insertMessage(in context: NSManagedObjectContext) -> Message? {
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message {
            message.messageId = Message.generateMessageIdString()
            return message
        }
        return nil
    }
    
    static func generateMessageIdString() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
}
