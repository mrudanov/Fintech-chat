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
        var userID: String
        var name: String?
        var message: String?
        var date: Date?
        var hasUnreadMessages: Bool
    }
    
    @IBOutlet weak var conversationsListTableView: UITableView!
    var dataManager: DataManager = GCDDataManager()
    var communicator: MultipeerCommunicator?
    var communicationManager: CommunicationManager?
    
    var onlineUsers: [ConversationPreview] = []
    var offlineUsers: [ConversationPreview] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        loadUserInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        communicationManager?.delegate = self
        sortOnlineUsers()
        onlineUsers = []
        offlineUsers = []
        communicationManager?.updateOnlineUsers()
    }

    // MARK: - Table View protocols
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? onlineUsers.count : offlineUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
        let preview = indexPath.section == 0 ?onlineUsers[indexPath.row] : offlineUsers[indexPath.row]
        
        if let conversationCell = cell as? ConversationTableViewCell {
            conversationCell.name = preview.name
            conversationCell.message = preview.message
            conversationCell.date = preview.date
            conversationCell.online = indexPath.section == 0
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
                    destinationVC.contactName = indexPath.section == 0 ? onlineUsers[indexPath.row].name : offlineUsers[indexPath.row].name
                    destinationVC.userID = indexPath.section == 0 ? onlineUsers[indexPath.row].userID : offlineUsers[indexPath.row].userID
                    destinationVC.communicationManager = communicationManager
                    communicationManager?.delegate = destinationVC
                }
            }
        }
    }
    
    // MARK: - Update UI
    func sortOnlineUsers() {
        onlineUsers = onlineUsers.sorted() {
            if $0.date != nil {
                if $1.date != nil {
                    return $0.date! > $1.date!
                } else {
                    return true
                }
            } else {
                if $1.date != nil {
                    return false
                } else {
                    if $0.name != nil && $0.name != nil {
                        return $0.name! < $0.name!
                    } else {
                        return $0.name != nil
                    }
                }
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.conversationsListTableView.reloadData()
        }
    }
    
    // MARK: - Load user data
    func loadUserInfo() {
        guard let fileName = ((UIApplication.shared.delegate) as? AppDelegate)?.userDataFileName else { return }
        // Get user data file directory
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            
            // Load data with data manager
            dataManager.loadUserInfo(from: fileURL) { [weak self] error, name, info, image in
                self?.communicationManager = CommunicationManager()
                self?.communicator = MultipeerCommunicator(visibleName: name)
                self?.communicator?.delegate = self?.communicationManager
                self?.communicationManager?.delegate = self
                self?.communicationManager?.communicator = self?.communicator
                self?.communicator?.online = true
            }
        } else {
            self.communicationManager = CommunicationManager()
            self.communicator = MultipeerCommunicator(visibleName: nil)
            self.communicator?.delegate = self.communicationManager
            self.communicationManager?.delegate = self
            self.communicationManager?.communicator = self.communicator
            self.communicator?.online = true
        }
    }
}

extension ConversationsListViewController: CommunicationManagerDelegate {
    func addOnlineUser(userID: String, name: String?, lastText: String?, lastTextDate: Date?) {
        print("Adding user \(name ?? userID)")
        if let index = onlineUsers.index(where: { $0.userID == userID }) {
            onlineUsers[index] = ConversationPreview(userID: userID, name: name, message: lastText, date: lastTextDate, hasUnreadMessages: false)
        } else {
            onlineUsers.append(ConversationPreview(userID: userID, name: name, message: lastText, date: lastTextDate, hasUnreadMessages: false))
        }
        sortOnlineUsers()
    }
    
    func removeOnlineUser(userID: String) {
        print("Removing user \(userID)")
        onlineUsers = onlineUsers.filter() { $0.userID != userID }
        sortOnlineUsers()
    }
    
    func recievedMessage(text: String, fromUser: String, date: Date) {
        if let index = onlineUsers.index(where: { $0.userID == fromUser }) {
            onlineUsers[index].message = text
            onlineUsers[index].date = date
        }
        sortOnlineUsers()
    }
}
