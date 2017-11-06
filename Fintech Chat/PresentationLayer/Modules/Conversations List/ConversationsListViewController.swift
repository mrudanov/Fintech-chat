//
//  ConversationsListViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 08/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

class ConversationsListViewController: UIViewController {
    struct ConversationPreview {
        var userID: String
        var name: String?
        var message: String?
        var date: Date?
        var hasUnreadMessages: Bool
    }
    
    @IBOutlet weak var conversationsListTableView: UITableView!
    
    static func initVC(with model: PreviewModel) -> ConversationsListViewController {
        let conversationVC = UIStoryboard(name: "ConversationsList", bundle: nil).instantiateViewController(withIdentifier: "ConversationsList") as! ConversationsListViewController
        conversationVC.previewDataModel = model
        return conversationVC
    }
    
    private var previewDataModel: PreviewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    private func navigateToCoversation(with userID: String, userName: String) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard appDelegate != nil else { return }
        
        let conversationAssembly = appDelegate!.rootAssembly.conversationModule
        
        let destinationVC = conversationAssembly.conversationViewController(userID: userID, userName: userName)
        
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
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Online" : "History"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let contactName = indexPath.section == 0 ? previewDataModel!.getOnlineUser(atIndex: indexPath.row).name : previewDataModel!.getOfflineUser(atIndex: indexPath.row).name
        
        let userID = indexPath.section == 0 ? previewDataModel!.getOnlineUser(atIndex: indexPath.row).userID : previewDataModel!.getOfflineUser(atIndex: indexPath.row).userID
        navigateToCoversation(with: userID, userName: contactName ?? "Unknown")
    }
}

extension ConversationsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return previewDataModel?.getOnlineUsersCount() ?? 0
        } else {
            return previewDataModel?.getOfflineUsersCount() ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath)
        let preview = indexPath.section == 0 ? previewDataModel?.getOnlineUser(atIndex: indexPath.row) : previewDataModel?.getOfflineUser(atIndex: indexPath.row)
        
        if let conversationCell = cell as? ConversationTableViewCell {
            conversationCell.name = preview?.name
            conversationCell.message = preview?.message
            conversationCell.date = preview?.date
            conversationCell.online = indexPath.section == 0
            conversationCell.hasUnreadMessages = preview?.hasUnreadMessages ?? false
            conversationCell.updateCellUI()
        }
        return cell
    }
}

extension ConversationsListViewController: PreviewDataModelDelegate {
    func didUpdatedUsersList() {
        DispatchQueue.main.async { [weak self] in
            self?.conversationsListTableView.reloadData()
        }
    }
}
