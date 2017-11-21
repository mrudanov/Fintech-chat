//
//  Parser.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 20/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

typealias Parser<Model> = (Data) -> Model?

class ParserFactory {
    static let imageListJSONParser: Parser<ImageListAPIModel> = { data in
        do {
            let jsonDecoder = JSONDecoder()
            let model = try jsonDecoder.decode(ImageListAPIModel.self, from: data)
            return model
        }
        catch {
            return nil
        }
    }
    
    static let dataParser: Parser<Data> = { data in
        return data
    }
}
