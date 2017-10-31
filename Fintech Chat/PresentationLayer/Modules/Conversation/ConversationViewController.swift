//
//  ConversationViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 08/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

class ConversationViewController: UIViewController {
    
    @IBOutlet weak var conversationTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var contactName: String?
    var userID = String()
    private var conversationDataModel: ConversationDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = contactName ?? "Unknown"
        conversationTableView.estimatedRowHeight = conversationTableView.rowHeight
        conversationTableView.rowHeight = UITableViewAutomaticDimension
        
        // add observers to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        messageTextField.delegate = self
    }
    
    static func initVC(with model: ConversationDataModel, userID: String, userName: String) -> ConversationViewController {
        let conversationVC = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewController(withIdentifier: "Conversation") as! ConversationViewController
        conversationVC.conversationDataModel = model
        conversationVC.contactName = userName
        conversationVC.userID = userID
        return conversationVC
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - keyboard and text edditing
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = -keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

extension ConversationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationDataModel?.getMessagesCount() ?? 0
    }
}

extension ConversationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageForCell = conversationDataModel?.getMessage(atIndex: indexPath.row)
        if messageForCell != nil {
            switch messageForCell! {
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
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "InputMessageCell", for: indexPath)
        }
    }
}

extension ConversationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text {
            if text != "" {
                conversationDataModel?.sendMessage(text: text, to: userID)
            }
        }
        textField.text = nil
        return true
    }
}

extension ConversationViewController: ConversationDataModelDelegate {
    func didFailedSendMessage(text: String) {
        DispatchQueue.main.async { [weak self] in
            let errorAlertController = UIAlertController(title: "Ошибка", message: "Не удалось отправить сообжение", preferredStyle: .alert)
            errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            errorAlertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
                if self != nil { self!.conversationDataModel?.sendMessage(text: text, to: self!.userID) }
            }))
            self?.present(errorAlertController, animated: true, completion: nil)
        }
    }
    
    func didAddMessage() {
        DispatchQueue.main.async { [weak self] in
            self?.conversationTableView.reloadData()
            let numberOfElements = self?.conversationTableView.numberOfRows(inSection: 0)
            let indexToScroll = (numberOfElements ?? 1) - 1
            let destinationIndexPath = IndexPath(item: indexToScroll, section: 0)
            self?.conversationTableView.scrollToRow(at: destinationIndexPath, at: .bottom, animated: true)
        }
    }
}


