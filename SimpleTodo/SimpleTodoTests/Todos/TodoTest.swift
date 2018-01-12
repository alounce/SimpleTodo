//
//  Todo.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import XCTest
import OHHTTPStubs
import Alamofire
@testable import SimpleTodo

/* WARNING: it worth to move that extension in separate file
 It just simplifies generation standard error stubs
 */
extension OHHTTPStubs {

    static func setupDownNetworkStubResponseBlock() -> OHHTTPStubsResponseBlock {
        return { _ -> OHHTTPStubsResponse in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
            return OHHTTPStubsResponse(error:notConnectedError)
        }
    }
    
    static func setupErrorStubResponseBlock(code: Int = 400) -> OHHTTPStubsResponseBlock {
        return { _ -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(data: Data(), statusCode: Int32(code), headers: nil)
        }
    }
}


class TodoTest: XCTestCase {
    
    func setupTodo() -> Todo {
        let JSON = ["id": 9,
                    "title": "Do something useful",
                    "details": "It should be really valuable",
                    "priority": 2,
                    "category": "Ideas",
                    "completed": true] as [String : Any]
        
        let model = TodoModel(json: JSON)
        let todo = Todo(model: model!)
        return todo
    }
    
    override func setUp() {
        super.setUp()
        // PUT CODE HERE
    }
    
    override func tearDown() {
        // PUT CODE HERE
        super.tearDown()
    }
    
    //MARK: - test initializers
    
    func test_init_with_model() {
        let JSON = ["id": 9,
                    "title": "Do something useful",
                    "details": "It should be really valuable",
                    "priority": 2,
                    "category": "Ideas",
                    "completed": true] as [String : Any]
        
        let model = TodoModel(json: JSON)
        XCTAssertNotNil(model)
        let subject = Todo(model: model!)
        XCTAssertNotNil(subject)
        XCTAssertEqual(subject.id, JSON["id"] as! Int)
        XCTAssertEqual(subject.title, JSON["title"] as! String)
        XCTAssertEqual(subject.details, JSON["details"] as! String)
        XCTAssertEqual(subject.priority, JSON["priority"] as! Int)
        XCTAssertEqual(subject.category, JSON["category"] as! String)
        XCTAssertEqual(subject.completed, JSON["completed"] as! Bool)
    }
    
    func test_init_with_title() {
        let expectedTitle = "Implement my cool idea"
        let subject = Todo(withTitle: expectedTitle)
        XCTAssertNotNil(subject)
        XCTAssertEqual(subject.id, -1)
        XCTAssertEqual(subject.title, expectedTitle)
        XCTAssertEqual(subject.details, "")
        XCTAssertEqual(subject.priority, 1)
        XCTAssertEqual(subject.category, "")
        XCTAssertEqual(subject.completed, false)
    }
    
    //MARK: - test properties
    
    func test_id() {
        let subject = Todo()
        XCTAssertEqual(subject.id, -1)
        let expectedValue = 7
        subject.id = expectedValue
        XCTAssertEqual(subject.id, expectedValue)
        XCTAssertTrue(subject.isDirty)
    }
    
    func test_title() {
        let subject = Todo()
        XCTAssertEqual(subject.title, "")
        let expectedValue = "Test"
        subject.title = expectedValue
        XCTAssertEqual(subject.title, expectedValue)
        XCTAssertTrue(subject.isDirty)
    }
    
    func test_details() {
        let subject = Todo()
        XCTAssertEqual(subject.details, "")
        let expectedValue = "Test"
        subject.details = expectedValue
        XCTAssertEqual(subject.details, expectedValue)
        XCTAssertTrue(subject.isDirty)
    }
    
    func test_priority() {
        let subject = Todo()
        XCTAssertEqual(subject.priority, 1)
        let expectedValue = 2
        subject.priority = expectedValue
        XCTAssertEqual(subject.priority, expectedValue)
        XCTAssertTrue(subject.isDirty)
    }
    
    func test_category() {
        let subject = Todo()
        XCTAssertEqual(subject.category, "")
        let expectedValue = "test"
        subject.category = expectedValue
        XCTAssertEqual(subject.category, expectedValue)
        XCTAssertTrue(subject.isDirty)
    }
    
    func test_completed() {
        let subject = Todo()
        XCTAssertEqual(subject.completed, false)
        let expectedValue = true
        subject.completed = expectedValue
        XCTAssertEqual(subject.completed, expectedValue)
        XCTAssertTrue(subject.isDirty)
    }
    
    //MARK: - test tracking changes
    
    // when we set the same properties, state of object must not change
    func test_setting_the_same_properties() {
        let expectedJSON = [
            "id": 2,
            "title": "Test change",
            "details": "Just for checking update works",
            "priority": 3,
            "category": "test",
            "completed": true
            ] as [String: Any]
        let model = TodoModel(json: expectedJSON)!
        let subject = Todo(model: model)
        XCTAssertFalse(subject.isDirty)
        subject.id = expectedJSON["id"] as! Int
        XCTAssertFalse(subject.isDirty)
        subject.title = expectedJSON["title"] as! String
        XCTAssertFalse(subject.isDirty)
        subject.details = expectedJSON["details"] as! String
        XCTAssertFalse(subject.isDirty)
        subject.priority = expectedJSON["priority"] as! Int
        XCTAssertFalse(subject.isDirty)
        subject.category = expectedJSON["category"] as! String
        XCTAssertFalse(subject.isDirty)
        subject.completed = expectedJSON["completed"] as! Bool
        XCTAssertFalse(subject.isDirty)
    }
    
    func test_applyChanges() {
        let expectedTitle = "My Change"
        let subject = Todo(withTitle: expectedTitle)
        XCTAssertTrue(subject.isDirty)
        let operationResult = subject.applyChanges()
        XCTAssertTrue(operationResult)
        XCTAssertFalse(subject.isDirty)
        XCTAssertEqual(subject.title, expectedTitle)
    }
    
    func test_cancelChanges() {
        let expectedJSON = [
            "id": 2,
            "title": "Test change",
            "details": "Just for checking update works",
            "priority": 3,
            "category": "test",
            "completed": true
            ] as [String: Any]
        let model = TodoModel(json: expectedJSON)!
        let subject = Todo(model: model)
        subject.title = expectedJSON["title"] as! String
        XCTAssertFalse(subject.isDirty)
        var operationResult = subject.cancelChanges()
        XCTAssertFalse(operationResult, "nothing to rollback")
        subject.title = "ABCDEF"
        XCTAssertTrue(subject.isDirty)
        operationResult = subject.cancelChanges()
        XCTAssertTrue(operationResult, "nothing to rollback")
        XCTAssertEqual(subject.title, expectedJSON["title"] as! String)
    }
    
    //MARK: - network tests (using stubs)
    
    
    /* POI: keep it DRY
     Use OHTTP stubs only for testing objects that is in charge for network communication
     */
    func test_load() {
        
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api =  WebAPIClient.getTodos
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse: OHHTTPStubsResponseBlock = { _ -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("getTodosAll.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"])
        }
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for loading all todos.")
        Todo.load { (todos, error) in
            XCTAssertNotNil(todos)
            XCTAssertNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    /* POI: Test failed path
     always try to test all path including unsuccessful
     */
    func test_load_network_error() {
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.getTodos
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse = OHHTTPStubs.setupDownNetworkStubResponseBlock()
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for downloading todos.")
        Todo.load { (todos, error) in
            XCTAssertNotNil(error)
            XCTAssertNil(todos)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_load_response_error() {
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api =  WebAPIClient.getTodos
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        let stubResponse = OHHTTPStubs.setupErrorStubResponseBlock()
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for loading all todos.")
        Todo.load { (todos, error) in
            XCTAssertNil(todos)
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_load_response_broken() {
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api =  WebAPIClient.getTodos
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        let stubResponse: OHHTTPStubsResponseBlock = { _ -> OHHTTPStubsResponse in
            return OHHTTPStubsResponse(
                fileAtPath: OHPathForFile("getTodosAll-broken.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"])
        }
        
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for loading all todos.")
        Todo.load { (todos, error) in
            XCTAssertNil(todos)
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        waitForExpectations(timeout: 5) { error in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_add_new() {
        let subject = Todo(withTitle: "New todo")
        let generatedId = 27
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.addTodo(todo: subject.model)
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        
        /* POI: Use OHTTP stubs with creaded in-place json dictionaries
         Reason: all code setup in the same test method, no need to navigate through files in project.
         Tests become more isolated and maintainable
         */
        let stubResponse: OHHTTPStubsResponseBlock = { _ -> OHHTTPStubsResponse in
            var expectedJSON = subject.model.asJSON()
            // patch expected JSON with fake generated ID
            expectedJSON["id"] = generatedId
            return OHHTTPStubsResponse(jsonObject: expectedJSON,
                                       statusCode: 201,
                                       headers: ["Content-Type":"application/json"])
        }
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        let expect = expectation(description: "Wait for update todo.")
        subject.update { todo, error in
            XCTAssertNil(error)
            XCTAssertFalse(todo.isDirty)
            XCTAssertEqual(todo.id, generatedId)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_update() {
        let subject = setupTodo()
        
        // check that subject doesn't have pending changes
        XCTAssertFalse(subject.isDirty)
        
        // make a change
        let expectedTitle = "Updated Todo item"
        subject.title = expectedTitle
        
        // make sure that subject has got pending changes
        XCTAssertTrue(subject.isDirty)
        
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.updateTodo(todo: subject.model)
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse: OHHTTPStubsResponseBlock = { _ -> OHHTTPStubsResponse in
            // we are expecting to get an updated version from service
            let expectedJSON = subject.model.asJSON()
            return OHHTTPStubsResponse(jsonObject: expectedJSON,
                                       statusCode: 201,
                                       headers: ["Content-Type":"application/json"])
        }
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        let expect = expectation(description: "Wait for update todo.")
        subject.update { todo, error in
            XCTAssertNil(error)
            XCTAssertFalse(todo.isDirty)
            XCTAssertEqual(todo.title, expectedTitle)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_update_network_error() {
        let subject = self.setupTodo()
        
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.updateTodo(todo: subject.model)
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse = OHHTTPStubs.setupDownNetworkStubResponseBlock()
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for update todo.")
        subject.update { _, error in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_update_response_error() {
        let subject = self.setupTodo()
        
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.updateTodo(todo: subject.model)
            let apply = request.url?.path == api.path
                     && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse = OHHTTPStubs.setupErrorStubResponseBlock()
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for update todo.")
        subject.update { (_, error) in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    // operation was successful but response is broken
    // we will not restore changes coz at the server side change has been applied
    func test_update_response_is_broken() {
        let subject = self.setupTodo()
        
        
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.updateTodo(todo: subject.model)
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse: OHHTTPStubsResponseBlock = { _ -> OHHTTPStubsResponse in
            var expectedJSON = subject.model.asJSON()
            // broke response by removing some key properties
            expectedJSON.removeValue(forKey: "title")
            return OHHTTPStubsResponse(jsonObject: expectedJSON,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for update todo.")
        subject.update { todo, error in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_delete() {
        let subject = self.setupTodo()

        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.deleteTodo(todoId: subject.model.id)
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse: OHHTTPStubsResponseBlock = { _ -> OHHTTPStubsResponse in
            let emptyJSON = [String: Any]()
            return OHHTTPStubsResponse(jsonObject: emptyJSON,
                                       statusCode: 200,
                                       headers: ["Content-Type":"application/json"])
        }
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for update todo.")
        subject.delete { todo, error in
            XCTAssertNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_delete_network_error() {
        let subject = setupTodo()

        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.deleteTodo(todoId: subject.model.id)
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse: OHHTTPStubsResponseBlock = { _ -> OHHTTPStubsResponse in
            let notConnectedError = NSError(domain: NSURLErrorDomain, code: URLError.notConnectedToInternet.rawValue)
            return OHHTTPStubsResponse(error:notConnectedError)
        }
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for update todo.")
        subject.delete { todo, error in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
    func test_delete_response_error() {
        let subject = setupTodo()
        
        // prepare stub
        let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
            let api = WebAPIClient.deleteTodo(todoId: subject.model.id)
            let apply = request.url?.path == api.path
                && request.httpMethod == api.method.rawValue
            return apply
        }
        
        let stubResponse = OHHTTPStubs.setupErrorStubResponseBlock()
        // register stub
        let s = stub(condition: stubCondition, response: stubResponse)
        
        let expect = expectation(description: "Wait for update todo.")
        subject.delete { todo, error in
            XCTAssertNotNil(error)
            expect.fulfill()
        }
        
        waitForExpectations(timeout: 1) { (error) in
            OHHTTPStubs.removeStub(s)
        }
    }
    
}
