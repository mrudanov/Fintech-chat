//
//  Conversation.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 12/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import CoreData

extension Conversation {
    static func insertConversation(in context: NSManagedObjectContext) -> Conversation? {
        if let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation {
            conversation.conversationId = Conversation.generateConversationIdString()
            return conversation
        }
        return nil
    }
    
    static func generateConversationIdString() -> String {
        let string = "\(arc4random_uniform(UINT32_MAX))+\(Date.timeIntervalSinceReferenceDate)+\(arc4random_uniform(UINT32_MAX))".data(using: .utf8)?.base64EncodedString()
        return string!
    }
}
