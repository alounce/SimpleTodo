//
//  TestEnvironmentStubInfoTest.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 1/31/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import XCTest
@testable import SimpleTodo

class TestEnvironmentStubInfoTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_method_path_statusCode_json() {
        let expectedMethod = HTTPMethod.read
        let expectedCode: Int32 = 200
        let expectedPath = "api/controller/resource"
        let expectedJSON = ["key":"value"]  as [String: String]
        let subject = TestEnvironmentStubInfo(path: expectedPath, json: expectedJSON)
        XCTAssertEqual(subject.method, expectedMethod)
        XCTAssertEqual(subject.path, expectedPath)
        XCTAssertEqual(subject.statusCode, expectedCode)
        XCTAssertEqual(subject.contentJSON as! [String: String], expectedJSON)
        XCTAssertNotEqual(subject.contentString, "")
        XCTAssertEqual(subject.key, "HTTPSTUB|GET|api/controller/resource")
        XCTAssertEqual(subject.value, "200|{\"key\":\"value\"}")
        XCTAssertNotNil(subject.description)
    }
    
    func testInit_method_path_statusCode_fileName_bundle() {
        let expectedMethod = HTTPMethod.read
        let expectedCode: Int32 = 200
        let expectedPath = "api/controller/resource"
        let thisBundle = Bundle(for: TestEnvironmentStubInfoTest.self)
        let subject = TestEnvironmentStubInfo(path: expectedPath,
                                              fileName: "getTodosAll",
                                              bundle: thisBundle)
        XCTAssertNotNil(subject)
        XCTAssertEqual(subject?.method, expectedMethod)
        XCTAssertEqual(subject?.path, expectedPath)
        XCTAssertEqual(subject?.statusCode, expectedCode)
        XCTAssertNotNil(subject?.contentJSON)
        XCTAssertGreaterThan(subject?.contentString.count ?? 0, 0)
        
        let subject2 = TestEnvironmentStubInfo(path: expectedPath,
                                              fileName: "notExistingFile",
                                              bundle: thisBundle)
        XCTAssertNil(subject2)
    }
    
    func testInit_environmentKey_value() {
        let expectedMethod = HTTPMethod.create
        let expectedCode: Int32 = 201
        let expectedPath = "api/controller/resource"
        
        let key = [TestEnvironmentStubInfo.kHttpStubHeader, expectedMethod.rawValue, expectedPath]
            .joined(separator: String(TestEnvironmentStubInfo.kSeparator))
        let value = ["\(expectedCode)", "[{\"key\": \"value\"}]"]
            .joined(separator: String(TestEnvironmentStubInfo.kSeparator))
        
        let subject = TestEnvironmentStubInfo(environmentKey: key, value: value)
        XCTAssertNotNil(subject)
        XCTAssertEqual(subject?.method, expectedMethod)
        XCTAssertEqual(subject?.path, expectedPath)
        XCTAssertEqual(subject?.statusCode, expectedCode)
        XCTAssertNotNil(subject?.contentJSON)
        XCTAssertGreaterThan(subject?.contentString.count ?? 0, 0)
        
        let subject2 = TestEnvironmentStubInfo(environmentKey: key, value: "201|")
        XCTAssertNil(subject2)
        
        let subject3 = TestEnvironmentStubInfo(environmentKey: "WrongKey", value: "WrongValue")
        XCTAssertNil(subject3)
    }
    
    func testIsStubInfo() {
        XCTAssertTrue(TestEnvironmentStubInfo.isStubInfo(TestEnvironmentStubInfo.kHttpStubHeader))
        XCTAssertFalse(TestEnvironmentStubInfo.isStubInfo("A\(TestEnvironmentStubInfo.kHttpStubHeader)"))
    }
    
}
