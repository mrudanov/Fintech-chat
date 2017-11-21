//
//  Request.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 20/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

struct RequestConfig<Model> {
    let request: IRequest
    let parser: Parser<Model>
}

protocol IRequest {
    var urlRequest: URLRequest? { get }
}

class PixabayRequest: IRequest {
    private let baseUrl: String =  "https://pixabay.com/api/"
    private let searchTerm: String = "avatar"
    private let imageType: String = "photo"
    private let apiKey: String
    private let imagesCount: Int
    private var getParameters: [String : String]  {
        return ["key": apiKey,
                "q" : searchTerm,
                "image_type" : imageType,
                "per_page" : "\(imagesCount)"]
    }
    
    private var urlString: String {
        let getParams = getParameters.flatMap({ "\($0.key)=\($0.value)"}).joined(separator: "&")
        return baseUrl + "?" + getParams
    }
    
    // MARK: - IRequest
    var urlRequest: URLRequest? {
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        return nil
    }
    
    // MARK: - Initialization
    init(apiKey: String, imagesCount: Int) {
        self.imagesCount = imagesCount
        self.apiKey = apiKey
    }
}

class SimpeImageRequest: IRequest {
    private let urlString: String
    
    // MARK: - IRequest
    var urlRequest: URLRequest? {
        if let url = URL(string: urlString) {
            return URLRequest(url: url)
        }
        return nil
    }
    
    // MARK: - Initialization
    init(urlString: String) {
        self.urlString = urlString
    }
}
