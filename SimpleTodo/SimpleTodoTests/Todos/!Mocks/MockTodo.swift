//
//  MockTodo.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 1/9/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import UIKit

@testable import SimpleTodo

/* Warning: this is a technique which is compormise between being pure and simple
 For cases when we still don't want to completelly re-implement tested object
 but we don't want to invoke network layer it possible to subclass tested object to have "kinda" Mock
 
 Used in Editor/TodoEditorViewControllerTest.swift
 */

class MockTodo: Todo {
    
    static var lastError: Error? = nil
    static var loadWasCalled: Bool = false
    static var loadShouldFail: Bool = false
    
    var updateWasCalled: Bool = false
    var updateShouldFail: Bool = false
    
    var deleteWasCalled: Bool = false
    var deleteShouldFail: Bool = false
    
    
    
    
    static func setupTestError() -> Error {
        return NSError(domain: "com.vivint.test",
                       code: 777,
                       userInfo: [kCFErrorLocalizedDescriptionKey as String: "Test Error"])
    }
    
    override open class func load(completion: @escaping ([Todo]?, Error?)->Void) {
        MockTodo.loadWasCalled = true
        MockTodo.lastError = MockTodo.loadShouldFail ? MockTodo.setupTestError() : nil
        completion([MockTodo(withTitle:"Loaded")], MockTodo.lastError)
    }
    
    override func update(completion: @escaping (Todo, Error?)->Void) {
        updateWasCalled = true
        MockTodo.lastError = updateShouldFail ? MockTodo.setupTestError() : nil
        completion(self, MockTodo.lastError)
    }
    
    override func delete(completion: @escaping (Todo, Error?)->Void) {
        deleteWasCalled = true
        MockTodo.lastError = updateShouldFail ? MockTodo.setupTestError() : nil
        completion(self, MockTodo.lastError)
    }
}
