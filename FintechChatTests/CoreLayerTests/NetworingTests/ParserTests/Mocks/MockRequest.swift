//
//  MockRequest.swift
//  FintechChatTests
//
//  Created by Mikhail Rudanov on 04/12/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import Foundation
@testable import Fintech_Chat

class MockRequest: IRequest {
    public var urlRequestWasCalled = false
    // MARK: - IRequest
    var urlRequest: URLRequest? {
        urlRequestWasCalled = true
        if let url = URL(string: "http://24.media.tumblr.com/tumblr_m2m62dh62T1qze0hyo1_500.jpg") {
            return URLRequest(url: url)
        }
        return nil
    }
}

struct MockParserFactory {
    static let mockParser: Parser<Data> = { data in
        return data
    }
}
