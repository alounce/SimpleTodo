//
//  TodoEditorViewControllerTest.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 1/5/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import XCTest
@testable import SimpleTodo

class MockTodosViewController:NSObject  {
    var editorDidChangeWasCalled: Bool = false
    var editorVC: TodoEditorViewController? = nil
    var data: Todo? = nil
}

extension MockTodosViewController: TodoEditorViewControllerDelegate {
    func editor(_ editor: TodoEditorViewController, didChange todo: Todo?) {
        editorDidChangeWasCalled = true
        editorVC = editor
        data = todo
    }
}

class TodoEditorViewControllerTest: XCTestCase {
    
    var editor: TodoEditorViewController!
    var parent: MockTodosViewController?
    var todo: MockTodo!
    
    override func setUp() {
        super.setUp()
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        editor = sb.instantiateViewController(withIdentifier: "TodoEditorViewController") as! TodoEditorViewController
        parent = MockTodosViewController()
        let todoJSON = [
            "id": 2,
            "title": "Test change",
            "details": "Just for checking update works",
            "priority": 3,
            "category": "test",
            "completed": true
            ] as [String: Any]
        let todoModel = TodoModel(json: todoJSON)!
        todo = MockTodo(model: todoModel)
        editor.configure(withDelegate: parent!, todo: todo, modificationType: .edit)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /* POI: Test outlets and actions wiring
     */
    func test_outlets() {
        _ = editor.view

        XCTAssertNotNil(editor.titleLabel)
        XCTAssertNotNil(editor.detailsLabel)
        XCTAssertNotNil(editor.categoryLabel)
        XCTAssertNotNil(editor.priorityLabel)
        
        XCTAssertNotNil(editor.titleText)
        XCTAssertNotNil(editor.detailsText)
        XCTAssertNotNil(editor.categoryText)
        XCTAssertNotNil(editor.prioritySegment)
        XCTAssertNotNil(editor.doneButton)
        
        XCTAssertNotNil(editor.doneButton.action)
        XCTAssertNotNil(editor.cancelButton.action)
    }
    
    func test_configure() {
        editor.configure(withDelegate: parent!, todo: todo, modificationType: .edit)
        
        _ = editor.view
        
        XCTAssert(editor.delegate === parent)
        XCTAssertEqual(editor.todo, todo)
        XCTAssertEqual(editor.modificationType, ModificationType.edit)
    }
    
    func test_syncData_forward() {
        _ = editor.view
        
        XCTAssertEqual(editor.titleText?.text, todo.title)
        XCTAssertEqual(editor.detailsText?.text, todo.details)
        XCTAssertEqual(editor.categoryText?.text, todo.category)
        XCTAssertEqual(editor.prioritySegment?.selectedSegmentIndex, todo.priority - 1)
        XCTAssertEqual(editor.title, "#\(todo.id)")
        
        editor.configure(withDelegate: parent!, todo: Todo(withTitle: "My new todo"), modificationType: .insert)
        editor.syncData()
        XCTAssertEqual(editor.title, "New")
    }
    
    func test_syncData_backward() {
        _ = editor.view
        let expectedTitle = "Changed Todo Title"
        let expectedDetails = "Changed Todo Details"
        let expectedCategory = "Changed Todo Category"
        let expectedPriority = 2
        
        editor.titleText?.text = expectedTitle
        editor.detailsText?.text = expectedDetails
        editor.categoryText?.text = expectedCategory
        editor.prioritySegment?.selectedSegmentIndex = expectedPriority - 1
        
        editor.syncData(forward: false)
        
        XCTAssertEqual(todo.title, expectedTitle)
        XCTAssertEqual(todo.details, expectedDetails)
        XCTAssertEqual(todo.priority, expectedPriority)
        XCTAssertEqual(todo.category, expectedCategory)
    }
    
    func test_onCancel() {
        // load controller
        _ = editor.view
        // change title
        editor.titleText.text = "Changed Todo Title"
        // clear delegate method invocation status
        parent?.editorDidChangeWasCalled = false
        // press cancel
        editor.onCancel(editor.cancelButton)
        // make sure that delegate method has been invoked
        XCTAssertTrue(parent!.editorDidChangeWasCalled)
    }
    
    func test_onDone() {
        // load controller
        _ = editor.view
        // change title
        let expectedTitle = "Changed Todo Title"
        editor.titleText.text = expectedTitle
        // clear delegate method invocation status
        parent?.editorDidChangeWasCalled = false
        // press done
        XCTAssertNotNil(editor.doneButton.action)
        
        editor.onDone(editor.doneButton)
        // make sure that change was synced back to BO
        XCTAssertEqual(todo.title, expectedTitle)
        // make sure that delegate method has been invoked
        XCTAssertTrue(parent!.editorDidChangeWasCalled)
        // make sure that delegate method has been invoked with proper arguments
        XCTAssertEqual(parent!.editorVC, editor)
        XCTAssertEqual(parent!.data, todo)
        // make sure that BO receives event for applying update
        XCTAssertTrue(todo.updateWasCalled)
    }
    
    func test_onDone_when_no_changes() {
        // load controller
        _ = editor.view
        // do not make any changes
        XCTAssertFalse(todo.isDirty)
        // clear delegate method invocation status
        parent?.editorDidChangeWasCalled = false
        // clear BO update method invocation status
        todo.updateWasCalled = false
        // press done
        editor.onDone(editor.doneButton)
        // make sure that delegate method has been invoked
        XCTAssertTrue(parent!.editorDidChangeWasCalled)
        // make sure that delegate method has been invoked with proper arguments
        XCTAssertEqual(parent!.editorVC, editor)
        // we do not pass changed object since there were no changes
        XCTAssertNil(parent!.data)
        // make sure that BO didn't try update
        XCTAssertFalse(todo.updateWasCalled)
    }
    
    func test_onDone_when_update_fails() {
        // load controller
        _ = editor.view
        // change title
        let expectedTitle = "Changed Todo Title"
        editor.titleText.text = expectedTitle
        // clear delegate method invocation status
        parent?.editorDidChangeWasCalled = false
        // clear BO update method invocation status
        todo.updateWasCalled = false
        MockTodo.lastError = nil
        // turn ON FAIL_ON_UPDATE mode for BO!!!
        todo.updateShouldFail = true
        // press done
        editor.onDone(editor.doneButton)
        // make sure that change was synced back to BO
        XCTAssertEqual(todo.title, expectedTitle)
        // make sure that BO receives event for applying update
        XCTAssertTrue(todo.updateWasCalled)
        // and update failed!!!!
        XCTAssertNotNil(MockTodo.lastError)
        // make sure that delegate method was not invoked - update failed so we still must be at editor screen
        XCTAssertFalse(parent!.editorDidChangeWasCalled)
        
    }
    
}
