//
//  ConversationsListViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 08/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    
    @IBOutlet weak var conversationsListTableView: UITableView!
    private var tableDataSource: IConversationsListTableDataSource?
    private var generator: IconsGenerator?
    
    static func initVC(with tableDataSource: IConversationsListTableDataSource) -> ConversationsListViewController {
        let conversationVC = UIStoryboard(name: "ConversationsList", bundle: nil).instantiateViewController(withIdentifier: "ConversationsList") as! ConversationsListViewController
        conversationVC.tableDataSource = tableDataSource
        return conversationVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        conversationsListTableView.delegate = self
        conversationsListTableView.dataSource = tableDataSource
        tableDataSource?.delegate = self
    }
    
    private func navigateToCoversation(with userID: String, userName: String, isOnline: Bool) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard appDelegate != nil else { return }
        
        let conversationAssembly = appDelegate!.rootAssembly.conversationModule
        let destinationVC = conversationAssembly.conversationViewController(userID: userID, userName: userName, isOnline: isOnline)
        
        show(destinationVC, sender: nil)
    }
    
    @IBAction func editBarButtonPressed(_ sender: UIBarButtonItem) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard appDelegate != nil else { return }
        
        let profileAssembly = appDelegate!.rootAssembly.profileModule
        
        let destinationVC = profileAssembly.embededInNavProfileVC()
        
        present(destinationVC, animated: true, completion: nil)
    }
}

extension ConversationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let user = tableDataSource?.getUserForRowAt(indexPath: indexPath), let id = user.userId {
            navigateToCoversation(with: id, userName: user.name ?? "Unknown", isOnline: user.isOnline)
        }
    }
}

extension ConversationsListViewController: ConversationsListTableDataSourceDelegate {
    func prepareCell(with user: User, at indexPath: IndexPath) -> UITableViewCell {
        let cell = conversationsListTableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
        
        if let conversationCell = cell as? ConversationTableViewCell {
            conversationCell.name = user.name
            conversationCell.message = user.conversation?.lastMessage?.text
            conversationCell.date = user.conversation?.lastMessage?.date
            conversationCell.online = user.isOnline
            conversationCell.updateCellUI()
            if let count = user.conversation?.unreadMessages?.count {
                conversationCell.hasUnreadMessages = count != 0
            } else {
                conversationCell.hasUnreadMessages = false
            }
        }
        
        return cell
    }
    
    func deleteSection(sectionIndex: Int) {
        conversationsListTableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    func insertSection(sectionIndex: Int) {
        conversationsListTableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
    }
    
    func beginUpdates() {
        conversationsListTableView.beginUpdates()
    }
    
    func endUpdates() {
        conversationsListTableView.endUpdates()
    }
    
    func deleteRow(at indexPath: IndexPath) {
        conversationsListTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func insertRow(at indexPath: IndexPath) {
        conversationsListTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func updateRow(at indexPath: IndexPath) {
        conversationsListTableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }
}
