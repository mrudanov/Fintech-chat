//
//  ImageCollectionViewController.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 19/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import UIKit

protocol ImageCollectionViewControllerDelegate: class {
    func didPickImage(_ image: UIImage?)
}

class ImageCollectionViewController: UIViewController {

    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let itemsPerRow: CGFloat = 3
    private let sectionInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    
    private var dataSource: [CellDisplayModel] = []
    private var model: IImageCollectionDataModel?
    
    weak var delegate: ImageCollectionViewControllerDelegate?
    
    static func initVC(model: IImageCollectionDataModel) -> ImageCollectionViewController {
        let collectionVC = UIStoryboard(name: "ImageCollection", bundle: nil).instantiateViewController(withIdentifier: "ImageCollection") as! ImageCollectionViewController
        collectionVC.model = model
        return collectionVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageCollectionView.dataSource = self
        imageCollectionView.delegate = self
        setupCollectionView()
    }

    @IBAction func backButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Private section
    
    private func setupCollectionView() {
        activityIndicator.startAnimating()
        model?.fetchImageList() { [weak self] dataSource, errorString in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                
                guard let dataSource = dataSource else {
                    self?.presentFetchErrorAlert(withMessage: errorString)
                    return
                }
                
                self?.dataSource = dataSource
                self?.imageCollectionView.reloadData()
            }
        }
    }
    
    private func setupImage(at indexPath: IndexPath, with image: UIImage?, errorString: String?) {
        guard let image = image else {
            print("Did not load image at index: \(indexPath.row)")
            return
        }
        
        dataSource[indexPath.row].image = image
        
        DispatchQueue.main.async { [weak self] in
            self?.imageCollectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func presentFetchErrorAlert(withMessage message: String?){
        let errorAlertController = UIAlertController(title: "Упс!", message: message ?? "", preferredStyle: .alert)
        errorAlertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        errorAlertController.addAction(UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            self?.setupCollectionView()
        }))
        self.present(errorAlertController, animated: true, completion: nil)
    }
}

extension ImageCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didPickImage(dataSource[indexPath.row].image)
        self.dismiss(animated: true)
    }
}

extension ImageCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath)
        if let imageCell = cell as? ImageCollectionViewCell {
            imageCell.profileImage.image = UIImage(named: "Profile placeholder")
            if let image = dataSource[indexPath.row].image {
                imageCell.profileImage.image = image
            } else {
                model?.fetchImage(at: dataSource[indexPath.row].imageUrl) { [weak self] image, errorString in
                    self?.setupImage(at: indexPath, with: image, errorString: errorString)
                }
            }
        }
        
        return cell
    }
}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
