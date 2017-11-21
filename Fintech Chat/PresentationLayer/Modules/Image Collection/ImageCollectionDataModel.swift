//
//  ImageCollectionDataSource.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 19/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
import UIKit

struct CellDisplayModel {
    var image: UIImage?
    let imageUrl: String
}

protocol IImageCollectionDataModel {
    func fetchImageList(completion: @escaping ([CellDisplayModel]?, String?) -> Void)
    func fetchImage(at urlString: String, completion: @escaping (UIImage?, String?) -> Void)
}

class ImageCollectionDataModel: IImageCollectionDataModel {
    private let imagesService: IImagesService
    
    init(imagesService: IImagesService) {
        self.imagesService = imagesService
    }
    
    func fetchImageList(completion: @escaping ([CellDisplayModel]?, String?) -> Void) {
        imagesService.loadImageList() { imageListModel, errorString in
            var displayModel: [CellDisplayModel] = []
            
            guard let imageListModel = imageListModel else {
                completion(nil, errorString)
                return
            }
            
            for image in imageListModel.hits {
                displayModel.append(CellDisplayModel(image: nil, imageUrl: image.webformatURL))
            }
            
            completion(displayModel, nil)
        }
    }
    
    func fetchImage(at urlString: String, completion: @escaping (UIImage?, String?) -> Void) {
        imagesService.loadImage(urlString: urlString) { imageData, _ in
            if let imageData = imageData, let image = UIImage(data: imageData) {
                completion(image, nil)
            }
        }
    }
}
