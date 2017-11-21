//
//  ImagesService.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 20/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol IImagesService {
    func loadImageList(completion: @escaping (ImageListAPIModel?, String?) -> Void)
    func loadImage(urlString: String, completion: @escaping (Data?, String?) -> Void)
}

struct ImageListAPIModel: Codable {
    let hits: [ImageAPIModel]
}

struct ImageAPIModel: Codable {
    let webformatURL: String
}

class ImagesService: IImagesService {
    
    private let requestSender: IRequestSender
    
    init(requestSender: IRequestSender) {
        self.requestSender = requestSender
    }
    
    func loadImageList(completion: @escaping (ImageListAPIModel?, String?) -> Void) {
        let request = RequestsFactory.PixabayRequests.imagesListRequest()
        requestSender.send(config: request) { (result: Result<ImageListAPIModel>) in
            switch result {
            case .success(let list):
                completion(list, nil)
            case .error(let error):
                completion(nil, error)
            }
        }
    }
    
    func loadImage(urlString: String, completion: @escaping (Data?, String?) -> Void) {
        let request = RequestsFactory.PixabayRequests.imageRequest(with: urlString)
        requestSender.send(config: request) { (result: Result<Data>) in
            switch result {
            case .success(let list):
                completion(list, nil)
            case .error(let error):
                completion(nil, error)
            }
        }
    }
}
