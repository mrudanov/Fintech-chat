//
//  Parser.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 20/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}

class JSONParser: IParser {
    typealias Model = ImageListAPIModel
    
    func parse(data: Data) -> ImageListAPIModel? {
        do {
            let jsonDecoder = JSONDecoder()
            let model = try jsonDecoder.decode(Model.self, from: data)
            return model
        }
        catch {
            return nil
        }
    }
}

class DataParser: IParser {
    typealias Model = Data
    
    func parse(data: Data) -> Data? {
        return data
    }
}
