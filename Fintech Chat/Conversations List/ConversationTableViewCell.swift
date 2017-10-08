//
//  ConversationTableViewCell.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 08/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

protocol ConversationCellConfiguration {
    var name: String? {get set}
    var message: String? {get set}
    var date: Date? {get set}
    var online: Bool {get set}
    var hasUnreadMessages: Bool {get set}
}

class ConversationTableViewCell: UITableViewCell, ConversationCellConfiguration {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Protocol
    var name: String?
    var message: String?
    var date: Date?
    var online: Bool = false
    var hasUnreadMessages: Bool = false
    
    // MARK: - Update UI
    func updateCellUI() {
        if name != nil {
            nameLabel.text = name
            nameLabel.font = UIFont.systemFont(ofSize: 17.0)
        } else {
            nameLabel.text = "Unknown"
            nameLabel.font = UIFont(name: "Avenir next", size: 19.0)!
        }
        if message != nil {
            messageLabel.text = message
            messageLabel.font = hasUnreadMessages ? UIFont.boldSystemFont(ofSize: 17.0) : UIFont.systemFont(ofSize: 17.0)
        } else {
            messageLabel.text = "No messages yet"
            messageLabel.font = UIFont(name: "Avenir next", size: 15.0)!
        }
        if let unwrapedDate = date {
            let formatter = DateFormatter()
            let calendar = NSCalendar.current
            if calendar.isDateInToday(unwrapedDate) {
                formatter.dateFormat = "HH:mm"
            } else {
                formatter.dateFormat = "dd MMM"
            }
            dateLabel?.text = formatter.string(from: unwrapedDate)
        } else {
            dateLabel?.text = ""
        }
        contentView.backgroundColor = online ? UIColor(red:1.00, green:0.99, blue:0.73, alpha:1.0) : UIColor.white
    }
}
