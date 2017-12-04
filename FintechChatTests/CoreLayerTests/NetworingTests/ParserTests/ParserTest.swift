//
//  ParserTest.swift
//  FintechChatTests
//
//  Created by Mikhail Rudanov on 04/12/2017.
//  Copyright © 2017 Mikhail Rudanov. All rights reserved.
//

import XCTest
@testable import Fintech_Chat

extension ImageAPIModel: Equatable {
    public static func ==(lhs: ImageAPIModel, rhs: ImageAPIModel) -> Bool {
        return lhs.webformatURL == rhs.webformatURL
    }
}

extension ImageListAPIModel: Equatable {
    public static func ==(lhs: ImageListAPIModel, rhs: ImageListAPIModel) -> Bool {
        return lhs.hits == rhs.hits
    }
}

class ParserTest: XCTestCase {
    
    let dataParser: Parser<Data> = ParserFactory.dataParser
    let imageListParser: Parser<ImageListAPIModel> = ParserFactory.imageListJSONParser
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDataParse() {
        // given
        let dataToParse = Data(capacity: 100)
        
        // when
        let parsedData = dataParser(dataToParse)
        
        // then
        XCTAssertEqual(parsedData, dataToParse)
    }
    
    func testImageListParse() {
        // given
        let fakeHits = [
            ImageAPIModel(webformatURL: "http://24.media.tumblr.com/tumblr_m2m62dh62T1qze0hyo1_500.jpg"),
            ImageAPIModel(webformatURL: "http://24.media.tumblr.com/tumblr_m2m620OHrV1qze0hyo1_400.jpg")]
        
        let fakeImageList = ImageListAPIModel(hits: fakeHits)
        let jsonEncoder = JSONEncoder()
        let dataToParse = try? jsonEncoder.encode(fakeImageList)
        // when
        guard dataToParse != nil else {
            assert(true, "Can't encode Fake Image List!")
            return
        }
        let parsedImageList = imageListParser(dataToParse!)
        
        // then
        XCTAssertNotNil(parsedImageList)
        XCTAssertEqual(parsedImageList!, fakeImageList)
    }
}
