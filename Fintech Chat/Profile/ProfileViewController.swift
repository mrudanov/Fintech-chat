//
//  ProfileViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 24/09/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

struct UserInfo: Codable {
    var name: String?
    var info: String?
    var image: String?
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var takePictureButton: RoundedButton!
    @IBOutlet weak var profileImage: RoundedImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var saveGCDButton: RoundedButton!
    @IBOutlet weak var saveOperationButton: RoundedButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var profileImageChanged = false
    
    var currentUserInfo: UserInfo?
    
    var dataManager: DataManager = OperationDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // To check photo load with GCG (Operation is defailt)
        //
        //dataManager = GCDDataManager()
        
        saveOperationButton.isEnabled = false
        saveGCDButton.isEnabled = false
        
        // Load saved user data
        loadUserInfo()
        
        // add observers to move view with keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self

        // Set button image "margins"
        takePictureButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if currentUserInfo?.name == nameTextField.text && currentUserInfo?.info == descriptionTextField.text && !profileImageChanged {
            saveGCDButton.isEnabled = false
            saveOperationButton.isEnabled = false
        } else {
            saveGCDButton.isEnabled = true
            saveOperationButton.isEnabled = true
        }
    }
    
    // MARK: - Save and load user data
    @IBAction func saveWirhGCDPressed(_ sender: RoundedButton) {
        self.dataManager = GCDDataManager()
        saveUserInfo()
    }
    
    @IBAction func saveWithOperationPressed(_ sender: RoundedButton) {
        self.dataManager = OperationDataManager()
        saveUserInfo()
    }
    
    func saveUserInfo() {
        // Get and prepare data
        currentUserInfo?.name = nameTextField.text
        currentUserInfo?.info = descriptionTextField.text
        if let unwrapedImage = profileImage.image{
            let imageData = UIImageJPEGRepresentation(unwrapedImage, 0.85)
            let base64Image = imageData?.base64EncodedString()
            currentUserInfo?.image = base64Image
        } else {
            currentUserInfo?.image = nil
        }
        
        // Disaple buttons
        saveGCDButton.isEnabled = false
        saveOperationButton.isEnabled = false
        
        guard currentUserInfo != nil else {return}
        guard let fileName = ((UIApplication.shared.delegate) as? AppDelegate)?.userDataFileName else {return}
        
        activityIndicator.startAnimating()
        
        // Get destination file directory
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            
            // Save with current manager
            dataManager.saveUserInfo(currentUserInfo!, to: fileURL) { [weak self] error in
                if error == nil {
                    self?.activityIndicator.stopAnimating()
                    self?.presentSuccessAlert()
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.presentSaveErrorAlert()
                }
            }
        }
    }
    
    func loadUserInfo() {
        guard let fileName = ((UIApplication.shared.delegate) as? AppDelegate)?.userDataFileName else {
            currentUserInfo = UserInfo(name: nil, info: nil, image: nil)
            return
        }
        activityIndicator.startAnimating()
        
        // Get user data file directory
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileName)
            
            // Load data with current data manager
            dataManager.loadUserInfo(from: fileURL) { [weak self] error, name, info, image in
                if error == nil {
                    self?.nameTextField.text = name
                    self?.descriptionTextField.text = info
                    if image != nil, image != "", let data = Data(base64Encoded: image!) {
                        self?.profileImage.image = UIImage(data: data)
                    }
                    self?.currentUserInfo = UserInfo(name: name, info: info, image: image)
                    self?.activityIndicator.stopAnimating()
                } else {
                    self?.currentUserInfo = UserInfo(name: nil, info: nil, image: nil)
                    self?.activityIndicator.stopAnimating()
                    self?.presentLoadErrorAlert()
                }
            }
        } else {
            currentUserInfo = UserInfo(name: nil, info: nil, image: nil)
            activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - Take profile picture
    @IBAction func TakePicturePressed(_ sender: RoundedButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alertController = UIAlertController(title: "Установить изображение профиля", message: "Можете выбрать фотографию из галереи, либо сделать новый снимок", preferredStyle: .actionSheet)
        let pickFromGallery = UIAlertAction(title: "Установить из галереи", style: .default) { action in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        let makePhoto = UIAlertAction(title: "Сделать фото", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera is not available")
                self.presentLoadImageErrorAlert(withMessage: "Камера не найдена на Вашем устройстве")
            }
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { action in
            
        }
        alertController.addAction(pickFromGallery)
        alertController.addAction(makePhoto)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - ImagePickerController Delegate methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = image
            saveGCDButton.isEnabled = true
            saveOperationButton.isEnabled = true
            profileImageChanged = true
        } else {
            print("Image retrieving error")
            self.presentLoadImageErrorAlert(withMessage: "Не удалось получить изображение")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Alerts
    func presentLoadImageErrorAlert(withMessage message: String){
        let errorAlertController = UIAlertController(title: "Упс!", message: message, preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(errorAlertController, animated: true, completion: nil)
    }
    
    func presentSaveErrorAlert(){
        let errorAlertController = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        errorAlertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.saveUserInfo()
        }))
        self.present(errorAlertController, animated: true, completion: nil)
    }
    
    func presentLoadErrorAlert(){
        let errorAlertController = UIAlertController(title: "Ошибка", message: "Не удалось загрузить данные", preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        errorAlertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.loadUserInfo()
        }))
        self.present(errorAlertController, animated: true, completion: nil)
    }
    
    func presentSuccessAlert(){
        let alertController = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}
