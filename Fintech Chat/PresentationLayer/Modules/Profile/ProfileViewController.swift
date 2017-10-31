//
//  ProfileViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 24/09/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

struct UserInfo {
    var name: String?
    var info: String?
    var image: UIImage?
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var takePictureButton: RoundedButton!
    @IBOutlet weak var profileImage: RoundedImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var saveGCDButton: RoundedButton!
    @IBOutlet weak var saveOperationButton: RoundedButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var profileImageChanged = false
    private var currentUserInfo: UserInfo?
    
    private var GCDModel: IProfileModel?
    private var operationModel: IProfileModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    static func initVC(GCDmodel: IProfileModel, operationModel: IProfileModel) -> ProfileViewController {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        profileVC.GCDModel = GCDmodel
        profileVC.operationModel = operationModel
        return profileVC
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
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
    
    // MARK: - Save and load user data
    @IBAction func saveWirhGCDPressed(_ sender: RoundedButton) {
        if GCDModel != nil { saveUserInfo(with: GCDModel!) }
    }
    
    @IBAction func saveWithOperationPressed(_ sender: RoundedButton) {
        if operationModel != nil { saveUserInfo(with: operationModel!) }
    }
    
    private func saveUserInfo(with model: IProfileModel) {
        perepareToSave()
        guard currentUserInfo != nil else {return}
        activityIndicator.startAnimating()
        model.saveUserInfo(currentUserInfo!) { [weak self] error in
            self?.handleSaveReponse(model: model, error: error)
        }
    }
    
    private func perepareToSave() {
        currentUserInfo?.name = nameTextField.text
        currentUserInfo?.info = descriptionTextField.text
        currentUserInfo?.image = profileImage.image
        saveGCDButton.isEnabled = false
        saveOperationButton.isEnabled = false
    }
    
    private func handleSaveReponse(model: IProfileModel, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            if error == nil {
                self?.presentSuccessAlert()
            } else {
                self?.presentSaveErrorAlert(model: model)
            }
        }
    }
    
    private func handleLoadReponse(error: Error?, userInfo: UserInfo?) {
        DispatchQueue.main.async { [weak self] in
            if error == nil {
                self?.currentUserInfo = userInfo
                self?.nameTextField.text = userInfo?.name
                self?.descriptionTextField.text = userInfo?.info
                self?.profileImage.image = userInfo?.image
                self?.activityIndicator.stopAnimating()
            } else {
                self?.currentUserInfo = UserInfo(name: nil, info: nil, image: nil)
                self?.activityIndicator.stopAnimating()
                self?.presentLoadErrorAlert()
            }
        }
    }
    
    private func loadUserInfo() {
        activityIndicator.startAnimating()
        GCDModel?.loadUserInfo() { [weak self] error, userInfo in
            self?.handleLoadReponse(error: error, userInfo: userInfo)
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
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(pickFromGallery)
        alertController.addAction(makePhoto)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
    
    func presentSaveErrorAlert(model: IProfileModel){
        let errorAlertController = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        errorAlertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.saveUserInfo(with: model)
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

extension ProfileViewController: UITextFieldDelegate {
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
}

extension ProfileViewController: UIImagePickerControllerDelegate {
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
}
