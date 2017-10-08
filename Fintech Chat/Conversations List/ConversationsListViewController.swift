//
//  ConversationsListViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 08/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct ConversationPreview {
        var name: String?
        var message: String?
        var date: Date?
        var online: Bool
        var hasUnreadMessages: Bool
    }
    
    @IBOutlet weak var conversationsListTableView: UITableView!
    var selectedContactName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    let fakeData: [Array<ConversationPreview>] = [
        [ConversationPreview(name: "Михаил Руданов", message: "Hi, wasup?", date: Date(), online: true, hasUnreadMessages: true),
        ConversationPreview(name: "Артем Киселев", message: "Доделал домашку?", date: Date(timeInterval: -10*60, since: Date()), online: true, hasUnreadMessages: true),
        ConversationPreview(name: "Steve Voznik", message: "Nice app, bro 😎", date: Date(timeInterval: -60*60, since: Date()), online: true, hasUnreadMessages: true),
        ConversationPreview(name: "Tim Cook", message: "Wanna invite you to our new campus 🏢", date: Date(timeInterval: -2*60*60, since: Date()), online: true, hasUnreadMessages: false),
        ConversationPreview(name: "Phil Schiller", message: "Yes, it's a great idea!", date: Date(timeInterval: -3*60*60, since: Date()), online: true, hasUnreadMessages: false),
        ConversationPreview(name: "Jonathan Ive", message: "Just saw your design project. Insane!", date: Date(timeInterval: -24*60*60, since: Date()), online: true, hasUnreadMessages: false),
        ConversationPreview(name: "Scott Forstall", message: "Testing IOS 11.1 on IPhone X prototype", date: Date(timeInterval: -28*60*60, since: Date()), online: true, hasUnreadMessages: true),
        ConversationPreview(name: "Craig Federighi", message: nil, date: nil, online: true, hasUnreadMessages: false),
        ConversationPreview(name: nil, message: "Привет, как деа?", date: Date(timeInterval: -48*60*60, since: Date()), online: true, hasUnreadMessages: true),
        ConversationPreview(name: nil, message: nil, date: nil, online: true, hasUnreadMessages: false)],
        
        [ConversationPreview(name: "Михаил Руданов v2", message: "Hi, wasup?", date: Date(), online: false, hasUnreadMessages: true),
        ConversationPreview(name: "Артем Киселев v2", message: "Доделал домашку?", date: Date(timeInterval: -10*60, since: Date()), online: false, hasUnreadMessages: true),
        ConversationPreview(name: "Steve Voznik v2", message: "Nice app, bro 😎", date: Date(timeInterval: -60*60, since: Date()), online: false, hasUnreadMessages: true),
        ConversationPreview(name: "Tim Cook v2", message: "Wanna invite you to our new campus 🏢", date: Date(timeInterval: -2*60*60, since: Date()), online: false, hasUnreadMessages: false),
        ConversationPreview(name: "Phil Schiller v2", message: "Yes, it's a great idea!", date: Date(timeInterval: -3*60*60, since: Date()), online: false, hasUnreadMessages: false),
        ConversationPreview(name: "Jonathan Ive v2", message: "Just saw your design project. Insane!", date: Date(timeInterval: -3.5*60*60, since: Date()), online: false, hasUnreadMessages: false),
        ConversationPreview(name: "Scott Forstall v2", message: "Testing IOS 11.1 on IPhone X prototype", date: Date(timeInterval: -24*60*60, since: Date()), online: false, hasUnreadMessages: true),
        ConversationPreview(name: "Craig Federighi v2", message: nil, date: nil, online: false, hasUnreadMessages: false),
        ConversationPreview(name: nil, message: "Привет, как деа? v2", date: Date(timeInterval: -26*60*60, since: Date()), online: false, hasUnreadMessages: true),
        ConversationPreview(name: nil, message: nil, date: nil, online: false, hasUnreadMessages: false)]]

    // MARK: - Table View protocols
    func numberOfSections(in tableView: UITableView) -> Int {
        return fakeData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fakeData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
        let preview = fakeData[indexPath.section][indexPath.row]
        
        if let conversationCell = cell as? ConversationTableViewCell {
            conversationCell.name = preview.name
            conversationCell.message = preview.message
            conversationCell.date = preview.date
            conversationCell.online = preview.online
            conversationCell.hasUnreadMessages = preview.hasUnreadMessages
            conversationCell.updateCellUI()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Online" : "History"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - Segue preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showConversation" {
            if let destinationVC = segue.destination as? ConversationViewController{
                if let indexPath = conversationsListTableView.indexPathForSelectedRow {
                    destinationVC.contactName = fakeData[indexPath.section][indexPath.row].name
                }
            }
        }
    }
}
