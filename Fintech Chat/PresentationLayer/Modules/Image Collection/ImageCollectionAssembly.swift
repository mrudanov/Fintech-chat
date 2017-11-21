//
//  ImageCollectionAssembly.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 20/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

class ImageCollectionAssembly {
    
    func embededInNavImageCollectionVC(withDelegate delegate: ImageCollectionViewControllerDelegate) -> UINavigationController {
        let navigationController = UIStoryboard(name: "ImageCollection", bundle: nil).instantiateViewController(withIdentifier: "ImageCollectionNavigation") as! UINavigationController
        let viewController = imageCollectionViewController()
        viewController.delegate = delegate
        navigationController.viewControllers[0] = viewController
        
        return navigationController
    }
    
    // MARK: - Private section
    private func imageCollectionViewController() -> ImageCollectionViewController {
        let sender = requestSender()
        let service = imageCollectionService(requestSender: sender)
        let model = imageCollectionDataModel(service: service)
        
        return ImageCollectionViewController.initVC(model: model)
    }
    
    private func requestSender() -> IRequestSender {
        return RequestSender()
    }
    
    private func imageCollectionService(requestSender: IRequestSender) -> IImagesService {
        return ImagesService(requestSender: requestSender)
    }
    
    private func imageCollectionDataModel(service: IImagesService) -> IImageCollectionDataModel {
        return ImageCollectionDataModel(imagesService: service)
    }
    
}
