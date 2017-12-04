//
//  RequestSenderTest.swift
//  FintechChatTests
//
//  Created by Mikhail Rudanov on 04/12/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import XCTest
@testable import Fintech_Chat

class RequestSenderTest: XCTestCase {
    
    let mockRequest = MockRequest()
    var mockParser = MockParserFactory.mockParser
    let requestSender = RequestSender()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        mockRequest.urlRequestWasCalled = false
    }
    
    func testThatUrlRequestFromRequestConfigWasCalled() {
        // given
        let mockConfig = RequestConfig(request: mockRequest, parser: mockParser)
        
        // when
        requestSender.send(config: mockConfig, completionHandler: {_ in })
        
        // then
        XCTAssertEqual(mockRequest.urlRequestWasCalled, true)
    }
    
    func testThatCompletionWasCalled() {
        // given
        let mockConfig = RequestConfig(request: mockRequest, parser: mockParser)
        let expectation = XCTestExpectation(description: "Parser was called from completionHandler")
        
        // when
        requestSender.send(config: mockConfig, completionHandler: {_ in
            expectation.fulfill()
        })
        
        // then
        wait(for: [expectation], timeout: 10.0)
    }
}
