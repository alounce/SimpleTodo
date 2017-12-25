//
//  TodoModelTest.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import XCTest
@testable import SimpleTodo

class TodoModelTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // PLACE CODE HERE
    }
    
    override func tearDown() {
        // PLACE CODE HERE
        super.tearDown()
    }
    
    func test_init_new() {
        let expectedId = -1
        let expectedTitle = ""
        let expectedDetails = ""
        let expectedPriority = 1
        let expectedCategory = ""
        let expectedCompleted = false
        
        let subject = TodoModel()
        
        XCTAssertNotNil(subject)
        XCTAssertEqual(subject.id, expectedId)
        XCTAssertEqual(subject.title, expectedTitle)
        XCTAssertEqual(subject.details, expectedDetails)
        XCTAssertEqual(subject.priority, expectedPriority)
        XCTAssertEqual(subject.category, expectedCategory)
        XCTAssertEqual(subject.completed, expectedCompleted)
        
    }
    
    func test_init_json() {
        let expectedId = 9
        let expectedTitle = "Do something useful"
        let expectedDetails = "It should be valuable"
        let expectedPriority = 1
        let expectedCategory = "something"
        let expectedCompleted = true
        
        let json = ["id": expectedId,
                    "title": expectedTitle,
                    "details": expectedDetails,
                    "priority": expectedPriority,
                    "category": expectedCategory,
                    "completed": expectedCompleted] as [String : Any]
        
        let subject = TodoModel(json: json)
        
        XCTAssertNotNil(subject)
        XCTAssertEqual(subject?.id, expectedId)
        XCTAssertEqual(subject?.title, expectedTitle)
        XCTAssertEqual(subject?.details, expectedDetails)
        XCTAssertEqual(subject?.priority, expectedPriority)
        XCTAssertEqual(subject?.category, expectedCategory)
        XCTAssertEqual(subject?.completed, expectedCompleted)
        
    }
    
    func test_init_json_failure() {
        let json = ["id": 9,
                    // json doesn't have a title property which causes initializer failure
                    //"title": expectedTitle as Any,
                    "details": "It should be valuable",
                    "priority": 1,
                    "category": "Important?",
                    "completed": true] as [String : Any]
        
        let subject = TodoModel(json: json)
        XCTAssertNil(subject, "Model has been created with no title?")
    }
    
}
