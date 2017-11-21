//
//  RequestSender.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 20/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol IRequestSender {
    func send<Parser, Model>(config: RequestConfig<Model, Parser>, completionHandler: @escaping (Result<Model>) -> Void)
}

enum Result<T> {
    case success(T)
    case error(String)
}

class RequestSender: IRequestSender {
    private let session = URLSession.shared
    
    func send<Model, Parser>(config: RequestConfig<Model, Parser>, completionHandler: @escaping (Result<Model>) -> Void) {
        guard let urlRequest = config.request.urlRequest else {
            completionHandler(Result.error("Url string can't be parsed to URL!"))
            return
        }
        
        let task = session.dataTask(with: urlRequest) { (data: Data?, response: URLResponse?, error: Error?) in
            if let error = error {
                completionHandler(Result.error(error.localizedDescription))
                return
            }
            
            guard let data = data, let parseModel: Model = config.parser.parse(data: data) else {
                completionHandler(Result.error("Did not recieved data!"))
                return
            }
            completionHandler(Result.success(parseModel))
        }
        
        task.resume()
    }
}

