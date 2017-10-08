//
//  MessageTableViewCell.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 08/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

protocol MessageCellConfiguration {
    var messageText: String? {get set}
}

class MessageTableViewCell: UITableViewCell, MessageCellConfiguration {
    @IBOutlet weak var messageLabel: UILabel!
    var messageText: String? {
        didSet{
            messageLabel?.text = messageText ?? ""
        }
    }
}
