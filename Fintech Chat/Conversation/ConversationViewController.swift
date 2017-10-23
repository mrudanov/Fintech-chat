//
//  ConversationViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 08/10/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

enum Message {
    case input(String)
    case output(String)
}

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var conversationTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var contactName: String?
    var userID = String()
    var communicationManager: CommunicationManager?
    
    var messages: [Message] = [ ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = contactName ?? "Unknown"
        conversationTableView.estimatedRowHeight = conversationTableView.rowHeight
        conversationTableView.rowHeight = UITableViewAutomaticDimension
        
        // add observers to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.recievedMessage(_:)), name: NSNotification.Name("DidRecievedMessage"), object: nil)
        
        messageTextField.delegate = self
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text {
            if text != "" {
                sendMessage(text: text)
            }
        }
        textField.text = nil
        return true
    }
    
    // MARK: - Send message
    func sendMessage(text: String) {
        communicationManager?.sendMessage(text: text, to: userID, completiionHandler: { [weak self] flag, error in
            if error != nil {
                print(error?.localizedDescription ?? "Can`t send message")
            } else {
                if flag {
                    self?.messages.append(Message.output(text))
                    self?.updateTable()
                } else {
                    self?.sendMessageError(sending: text)
                }
            }
        })
    }
    
    
    // MARK: - Tabel view protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageForCell = messages[indexPath.row]
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
    
    // MARK: - Update UI
    func updateTable() {
        DispatchQueue.main.async { [weak self] in
            self?.conversationTableView.reloadData()
            let destinationIndexPath = IndexPath(item: (self?.messages.count ?? 0) - 1, section: 0)
            self?.conversationTableView.scrollToRow(at: destinationIndexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - Alerts
    func sendMessageError(sending text: String){
        let errorAlertController = UIAlertController(title: "Ошибка", message: "Не удалось отправить сообжение", preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        errorAlertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.sendMessage(text: text)
        }))
        self.present(errorAlertController, animated: true, completion: nil)
    }
    
    // MARK: - Handle notifications
    @objc func recievedMessage(_ notification: NSNotification) {
        guard let text = notification.userInfo!["text"] as? String else {return}
        messages.append(Message.input(text))
        updateTable()
    }
}


