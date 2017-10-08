//
//  ConversationViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 08/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    enum message {
        case input(String)
        case output(String)
    }
    
    @IBOutlet weak var conversationTableView: UITableView!
    var contactName: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = contactName ?? "Unknown"
        conversationTableView.estimatedRowHeight = conversationTableView.rowHeight
        conversationTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    let fakeMessageData: [message] = [
        message.input("A"),
        message.output("B"),
        message.input("This is 30 characters example."),
        message.output("This is 30 characters example."),
        message.input("This is 300 characters example. Bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla."),
        message.output("This is 300 characters example. Bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla bla.")]
    
    // MARK: - Tabel view protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fakeMessageData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageForCell = fakeMessageData[indexPath.row]
        switch messageForCell {
        case let .input(messageText):
            let cell = tableView.dequeueReusableCell(withIdentifier: "InputMessageCell", for: indexPath)
            if let conversationCell = cell as? MessageTableViewCell {
                conversationCell.messageText = messageText
            }
            return cell
        case let .output(messageText):
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutputMessageCell", for: indexPath)
            if let conversationCell = cell as? MessageTableViewCell {
                conversationCell.messageText = messageText
            }
            return cell
        }
    }
}
