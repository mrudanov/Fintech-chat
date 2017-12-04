//
//  RequestTest.swift
//  FintechChatTests
//
//  Created by Mikhail Rudanov on 04/12/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import XCTest
@testable import Fintech_Chat

class RequestTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPixabayRequest() {
        // given
        guard let url = URL(string: "https://pixabay.com/api/?q=avatar&key=MyAppKey&image_type=photo&per_page=90") else {
            assert(true, "Can't make URL from fake String!")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // when
        let pixabayRequest = PixabayRequest(apiKey: "MyAppKey", imagesCount: 90)
        let pixabayUIUrlRequest = pixabayRequest.urlRequest
        
        // then
        XCTAssertNotNil(pixabayUIUrlRequest)
        XCTAssertEqual(urlRequest, pixabayUIUrlRequest!)
    }
    
    func testSimpleStringRequest() {
        // given
        let urlString = "https://pixabay.com/api/?q=avatar&key=MyAppKey&image_type=photo&per_page=90"
        
        guard let url = URL(string: urlString) else {
            assert(true, "Can't make URL from fake String!")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // when
        let simpleImageRequest = SimpeImageRequest(urlString: urlString).urlRequest
        
        // then
        XCTAssertNotNil(simpleImageRequest)
        XCTAssertEqual(urlRequest, simpleImageRequest!)
    }
    
}
