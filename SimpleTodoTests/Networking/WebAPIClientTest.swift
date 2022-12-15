//
//  WebAPIClientTest.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 1/9/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import XCTest
import Moya
import Alamofire

@testable import SimpleTodo

class WebAPIClientTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testAPI() {
        let api: WebAPIClient = .getTodo(todoId:3)
        let expected = api.parameterEncoding
        XCTAssert(type(of: expected) == JSONEncoding.self)
        XCTAssertEqual(api.path, "/alounce/demo/todos/3")
        XCTAssertNotNil(api.sampleData)
        XCTAssertEqual(api.method, .get)
        
        
    }
    
}
