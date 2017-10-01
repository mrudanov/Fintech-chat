//
//  ProfileViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 24/09/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var takePictureButton: RoundedButton!
    @IBOutlet weak var profileImage: RoundedImageView!
    @IBOutlet weak var editProfileButton: RoundedButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        // Ответ на пункт 3.2 ДЗ. Вознивает ошибка доступа к непроинициализированному обьекту,
        // т.к. элементы из storyboard'а будут загружены после инициализации ViewController'а.
        //
        //print("Edit button frame: width - \(editProfileButton.frame.width), height - \(editProfileButton.frame.height).")
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Edit profile button frame inside viewDidLoad: width - \(editProfileButton.frame.width), height - \(editProfileButton.frame.height).")

        // Set in-button image "margins"
        takePictureButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Ответ на пункт 3.4 ДЗ. Значения frame для кнопки одинаковы в методах viewDidLoad и viewWillAppear,
        // т.к. кнопки в данные моменты жизненного цикла проинициализированны из storyboard'а.
        //
        print("Edit profile button frame inside viewWillAppear: width - \(editProfileButton.frame.width), height - \(editProfileButton.frame.height).")
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Ответ на пункт 3.4 ДЗ. Значения frame для кнопки в методе viewDidAppear отличается от значений во viewWillAppear
        // и viewDidLoad, т.к происходит пересчет параметров уже для размеров дисплея эмулятора.
        // (Экран девайса в сториборде имеет меньшее разрешение, чем в симуляторе (SE vs X).)
        //
        print("Edit profile button frame inside viewDidAppear: width - \(editProfileButton.frame.width), height - \(editProfileButton.frame.height).")
        super.viewDidAppear(animated)
    }
    
    // MARK: - Take profile picture
    @IBAction func TakePicturePressed(_ sender: RoundedButton) {
        // Base task implementation
        print("Выбери изображение профиля")
        
        // "Star" task implementation
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
                self.presentErrorAlert(withMessage: "Камера не найдена на Вашем устройстве")
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
        } else {
            print("Image retrieving error")
            self.presentErrorAlert(withMessage: "Не удалось получить изображение")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Error alert
    func presentErrorAlert(withMessage message: String){
        let errorAlertController = UIAlertController(title: "Упс!", message: message, preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(errorAlertController, animated: true, completion: nil)
    }
}
