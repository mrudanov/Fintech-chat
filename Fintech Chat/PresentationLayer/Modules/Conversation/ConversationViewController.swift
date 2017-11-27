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
    @IBOutlet weak var sendButton: RoundedButton!
    
    private let enabledButtonColor: UIColor = UIColor(red:0.22, green:0.87, blue:0.91, alpha:1.0)
    private let disabledButtonColor: UIColor = UIColor(red:0.54, green:0.54, blue:0.54, alpha:1.0)
    private let titleOnlineColor: UIColor = UIColor(red:0.36, green:0.71, blue:0.30, alpha:1.0)
    private let titleOfflineColor: UIColor = UIColor.black
    private let navigationTitleLabelView = UILabel.init(frame: CGRect(x: 0, y: 0, width: 250, height: 44))
    
    
    var contactName: String?
    var userID = String()
    var isOnline = Bool()
    
    private var textFieldIsEmpty: Bool = true
    private var sendButtonIsAnimating: Bool = false
    private var tableDataSource: IConversationTableDataSource?
    
    static func initVC(with tableDataSource: IConversationTableDataSource, userID: String, userName: String, online: Bool) -> ConversationViewController {
        let conversationVC = UIStoryboard(name: "Conversation", bundle: nil).instantiateViewController(withIdentifier: "Conversation") as! ConversationViewController
        conversationVC.tableDataSource = tableDataSource
        conversationVC.contactName = userName
        conversationVC.userID = userID
        conversationVC.isOnline = online
        return conversationVC
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupNavigationTitle()
        setupTableView()
        setupTextField()
        setupKeyboardObservers()
        setupSendButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupNavigationTitle()
    }
    
    private func setupTableView() {
        conversationTableView.estimatedRowHeight = conversationTableView.rowHeight
        conversationTableView.rowHeight = UITableViewAutomaticDimension
        conversationTableView.dataSource = tableDataSource
        tableDataSource?.delegate = self
        scrollToLastRow()
    }
    
    // MARK: - Navigation bar
    func setupNavigationTitle() {
        navigationTitleLabelView.backgroundColor = UIColor.clear
        navigationTitleLabelView.textAlignment = .center
        navigationTitleLabelView.font = UIFont.boldSystemFont(ofSize: 16.0)
        navigationTitleLabelView.adjustsFontSizeToFitWidth = true
        navigationTitleLabelView.text = contactName ?? "Unknown"
        navigationItem.titleView = navigationTitleLabelView
        
        if isOnline {
            navigationTitleLabelView.textColor = titleOnlineColor
            navigationItem.titleView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } else {
            navigationTitleLabelView.textColor = titleOfflineColor
        }
    }
    
    func updateNavigationBarTitle() {
        navigationTitleLabelView.layer.removeAllAnimations()
        if isOnline {
            UIView.transition(with: navigationTitleLabelView, duration: 1, options: .transitionCrossDissolve, animations: {
                self.navigationTitleLabelView.textColor = self.titleOnlineColor
                self.navigationItem.titleView?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: nil)
        } else {
            UIView.transition(with: navigationTitleLabelView, duration: 1, options: .transitionCrossDissolve, animations: {
                self.navigationTitleLabelView.textColor = self.titleOfflineColor
                 self.navigationItem.titleView?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }
    }
    
    // MARK: - Send button
    private func setupSendButton() {
        sendButton.isEnabled = false
        sendButton.backgroundColor = disabledButtonColor
    }
    
    @IBAction func didPressSendButton(_ sender: RoundedButton) {
        if let text = messageTextField.text {
            tableDataSource?.sendMessage(text: text, to: userID) { [weak self, text] flag, error in
                flag ? self?.didAddMessage() : self?.didFailedSendMessage(text: text)
            }
        }
        messageTextField.text = nil
        textFieldIsEmpty = true
        updateSendButton()
    }
    
    private func updateSendButton() {
        if isOnline && !textFieldIsEmpty {
            if !sendButton.isEnabled {
                sendButton.isEnabled = true
                animateSendButton(toColor: enabledButtonColor)
            }
        } else {
            if sendButton.isEnabled {
                sendButton.isEnabled = false
                animateSendButton(toColor: disabledButtonColor)
            }
        }
    }
    
    private func animateSendButton(toColor: UIColor) {
        if !sendButtonIsAnimating {
            sendButtonIsAnimating = true
            UIView.animate(withDuration: 0.5, animations: {
                self.sendButton.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                self.sendButton.backgroundColor = toColor
            }) { finished in
                if finished {
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { timer in
                        UIView.animate(withDuration: 0.5) {
                            self.sendButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            self.sendButtonIsAnimating = false
                        }
                    }
                } else {
                    self.sendButtonIsAnimating = false
                }
            }
        }
    }
    
    // MARK: - keyboard and text edditing
    private func setupTextField() {
        messageTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        messageTextField.delegate = self
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = -keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text == "" {
            if !textFieldIsEmpty {
                textFieldIsEmpty = true
                updateSendButton()
            }
        } else {
            if textFieldIsEmpty {
                textFieldIsEmpty = false
                updateSendButton()
            }
        }
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
        return true
    }
}

extension ConversationViewController: ConversationTableDataSourceDelegate {
    func userBecameOnline() {
        if !isOnline {
            DispatchQueue.main.async { [weak self] in
                self?.isOnline = true
                self?.updateSendButton()
                self?.updateNavigationBarTitle()
            }
        }
    }
    
    func userBecameOffline() {
        if isOnline {
            DispatchQueue.main.async { [weak self] in
                self?.isOnline = false
                self?.updateSendButton()
                self?.updateNavigationBarTitle()
            }
        }
    }
    
    func prerapeCell(with message: Message, at indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if message.sender?.userId == userID {
            cell = conversationTableView.dequeueReusableCell(withIdentifier: "InputMessageCell", for: indexPath)
        } else {
            cell = conversationTableView.dequeueReusableCell(withIdentifier: "OutputMessageCell", for: indexPath)
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

