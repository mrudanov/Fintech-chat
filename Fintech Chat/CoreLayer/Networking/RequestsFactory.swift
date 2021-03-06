//
//  RequestFactory.swift
//  Fintech Chat
//
//  Created by Mikhail Rudanov on 20/11/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation

struct RequestsFactory {
    struct PixabayRequests {
        static func imagesListRequest() -> RequestConfig<ImageListAPIModel> {
            let request = PixabayRequest(apiKey: "7109883-b07037ae17b8ec5baaa500044", imagesCount: 90)
            return RequestConfig(request: request, parser: ParserFactory.imageListJSONParser)
        }
        
        static func imageRequest(with: String) -> RequestConfig<Data> {
            let request = SimpeImageRequest(urlString: with)
            return RequestConfig(request: request, parser: ParserFactory.dataParser)
        }
    }
}


