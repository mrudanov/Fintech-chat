//
//  ProfileViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 24/09/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

struct UIUserInfo {
    var name: String?
    var info: String?
    var image: UIImage?
}

class ProfileViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var takePictureButton: RoundedButton!
    @IBOutlet weak var profileImage: RoundedImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var saveButton: RoundedButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var profileImageChanged = false
    private var currentUserInfo: UIUserInfo?
    
    private var model: IProfileModel?
    
    private let enabledButtonColor: UIColor = UIColor(red:0.32, green:0.56, blue:0.93, alpha:1.0)
    private let disabledButtonColor: UIColor = UIColor(red:0.54, green:0.54, blue:0.54, alpha:1.0)
    
    static func initVC(model: IProfileModel) -> ProfileViewController {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "Profile") as! ProfileViewController
        profileVC.model = model
        return profileVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        saveButton.backgroundColor = disabledButtonColor
        
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
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    // MARK: - Save and load user data
    @IBAction func saveButtonPressed(_ sender: RoundedButton) {
         saveUserInfo()
    }
    
    private func saveUserInfo() {
        perepareToSave()
        guard currentUserInfo != nil else {return}
        activityIndicator.startAnimating()
        model?.saveUserInfo(currentUserInfo!) { [weak self] in
            self?.handleSaveReponse()
        }
    }
    
    private func perepareToSave() {
        currentUserInfo?.name = nameTextField.text
        currentUserInfo?.info = descriptionTextField.text
        currentUserInfo?.image = profileImage.image
        saveButton.isEnabled = false
        saveButton.backgroundColor = disabledButtonColor
    }
    
    private func handleSaveReponse() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.presentSuccessAlert()
        }
    }
    
    private func handleLoadReponse(userInfo: UIUserInfo) {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
            self?.currentUserInfo = userInfo
            self?.nameTextField.text = userInfo.name
            self?.descriptionTextField.text = userInfo.info
            if let image = userInfo.image {
               self?.profileImage.image = image
            }
        }
    }
    
    private func loadUserInfo() {
        activityIndicator.startAnimating()
        if let userInfo = model?.loadUserInfo() {
            handleLoadReponse(userInfo: userInfo)
        }
    }
    
    // MARK: - Take profile picture
    @IBAction func TakePicturePressed(_ sender: RoundedButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let alertController = UIAlertController(title: "Установить изображение профиля", message: "Можете выбрать фотографию из галереи, либо сделать новый снимок", preferredStyle: .actionSheet)
        let pickFromGallery = UIAlertAction(title: "Установить из галереи", style: .default) { _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        let makePhoto = UIAlertAction(title: "Сделать фото", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            } else {
                print("Camera is not available")
                self.presentLoadImageErrorAlert(withMessage: "Камера не найдена на Вашем устройстве")
            }
        }
        
        let pickFromAPI = UIAlertAction(title: "Загрузить", style: .default) { [weak self] _ in
            self?.showImageCollection()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(pickFromGallery)
        alertController.addAction(makePhoto)
        alertController.addAction(pickFromAPI)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func showImageCollection() {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        guard appDelegate != nil else { return }
        
        let imageCollectionAssembly = appDelegate!.rootAssembly.imageCollectionModule
        let destinationVC = imageCollectionAssembly.embededInNavImageCollectionVC(withDelegate: self)
        
        present(destinationVC, animated: true, completion: nil)
    }
    
    // MARK: - Alerts
    func presentLoadImageErrorAlert(withMessage message: String){
        let errorAlertController = UIAlertController(title: "Упс!", message: message, preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(errorAlertController, animated: true, completion: nil)
    }
    
    func presentSuccessAlert(){
        let alertController = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension ProfileViewController: ImageCollectionViewControllerDelegate {
    func didPickImage(_ image: UIImage?) {
        if let image = image {
            saveButton.isEnabled = true
            saveButton.backgroundColor = enabledButtonColor
            profileImageChanged = true
            profileImage.image = image
        }
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if currentUserInfo?.name == nameTextField.text && currentUserInfo?.info == descriptionTextField.text && !profileImageChanged {
            saveButton.isEnabled = false
            saveButton.backgroundColor = disabledButtonColor
        } else {
            saveButton.isEnabled = true
            saveButton.backgroundColor = enabledButtonColor
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            profileImage.image = image
            saveButton.isEnabled = true
            saveButton.backgroundColor = enabledButtonColor
            profileImageChanged = true
        } else {
            print("Image retrieving error")
            self.presentLoadImageErrorAlert(withMessage: "Не удалось получить изображение")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
