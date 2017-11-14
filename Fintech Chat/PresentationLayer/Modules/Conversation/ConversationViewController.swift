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
    private var tableDataSource: IConversationTableDataSource?
    
    static func initVC(with tableDataSource: IConversationTableDataSource, userID: String, userName: String) -> ConversationViewController {
        let conversationVC = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewController(withIdentifier: "Conversation") as! ConversationViewController
        conversationVC.tableDataSource = tableDataSource
        conversationVC.contactName = userName
        conversationVC.userID = userID
        return conversationVC
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = contactName ?? "Unknown"
        conversationTableView.estimatedRowHeight = conversationTableView.rowHeight
        conversationTableView.rowHeight = UITableViewAutomaticDimension
        
        // add observers to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        messageTextField.delegate = self
        conversationTableView.dataSource = tableDataSource
        tableDataSource?.delegate = self
        scrollToLastRow()
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
    
    // MARK: - Helper functions
    private func didFailedSendMessage(text: String) {
        DispatchQueue.main.async { [weak self] in
            let errorAlertController = UIAlertController(title: "Ошибка", message: "Не удалось отправить сообжение", preferredStyle: .alert)
            errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            errorAlertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.tableDataSource?.sendMessage(text: text, to: strongSelf.userID) { [weak self, text] flag, error in
                    flag ? self?.didAddMessage() : self?.didFailedSendMessage(text: text)
                }
            }))
            self?.present(errorAlertController, animated: true, completion: nil)
        }
    }
    
    private func didAddMessage() {
        DispatchQueue.main.async { [weak self] in
            self?.conversationTableView.reloadData()
            let numberOfElements = self?.conversationTableView.numberOfRows(inSection: 0)
            let indexToScroll = (numberOfElements ?? 1) - 1
            let destinationIndexPath = IndexPath(item: indexToScroll, section: 0)
            self?.conversationTableView.scrollToRow(at: destinationIndexPath, at: .bottom, animated: true)
        }
    }
    
    private func scrollToLastRow() {
        let lastRow = conversationTableView.numberOfRows(inSection: 0) - 1
        if lastRow <= 0 { return }
        let indexPath = IndexPath(row: lastRow, section: 0)
        conversationTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
}

extension ConversationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text {
            if text != "" {
                tableDataSource?.sendMessage(text: text, to: userID) { [weak self, text] flag, error in
                    flag ? self?.didAddMessage() : self?.didFailedSendMessage(text: text)
                }
            }
        }
        textField.text = nil
        return true
    }
}

extension ConversationViewController: ConversationTableDataSourceDelegate {
    func prerapeCell(with message: Message, at indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if message.sender?.userId == userID {
            cell = conversationTableView.dequeueReusableCell(withIdentifier: "OutputMessageCell", for: indexPath)
        } else {
            cell = conversationTableView.dequeueReusableCell(withIdentifier: "InputMessageCell", for: indexPath)
        }
        if let conversationCell = cell as? MessageTableViewCell {
            conversationCell.messageText = message.text
        }
        return cell
    }
    
    func beginUpdates() {
        conversationTableView.beginUpdates()
    }
    
    func endUpdates() {
        conversationTableView.endUpdates()
        scrollToLastRow()
    }
    
    func deleteRow(at indexPath: IndexPath) {
        conversationTableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func insertRow(at indexPath: IndexPath) {
        conversationTableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func updateRow(at indexPath: IndexPath) {
        conversationTableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

