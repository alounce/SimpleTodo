//
//  TodosViewModel.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 12/25/17.
//  Copyright © 2017 Alexander Karpenko. All rights reserved.
//

import XCTest
@testable import SimpleTodo

class TodosViewModelTest: XCTestCase {
    var expectedTodos: [Todo]!
    override func setUp() {
        super.setUp()
        expectedTodos =  [
            MockTodo(withTitle: "Do this!"),
            MockTodo(withTitle: "Then do this!"),
            MockTodo(withTitle: "And finaly do this!")
        ]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_numberOfGroups() {
        // should always be 1
        let expected: Int = 1
        let subject = TodosViewModel()
        XCTAssertEqual(subject.numberOfGroups(), expected)
    }
    
    func test_numberOfItems_inGroup() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let expected: Int = expectedTodos.count
        XCTAssertEqual(subject.numberOfItems(inGroup: 0), expected)
    }
    
    func test_numberOfItems_inGroup_wrongIndex() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let expected: Int = 0
        XCTAssertEqual(subject.numberOfItems(inGroup: 22), expected)
    }
    
    func test_item_forRow() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let expected: Todo = expectedTodos[1]
        XCTAssert(subject.item(forRow: 1)! === expected)
    }
    
    func test_item_forRow_inGroup() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let expected: Todo = expectedTodos[2]
        XCTAssert(subject.item(forRow: 2, inGroup: 0)! === expected)
    }
    
    /// should return nil if asking item out of array range
    func test_item_forRow_wrongIndex() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        XCTAssertNil(subject.item(forRow: 22, inGroup: 0))
    }
    
    func test_item_byIndexPath() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let ip = IndexPath(row: 1, section: 0)
        let expected: Todo = expectedTodos[1]
        let actual: Todo = subject.item(byIndexPath: ip)!
        XCTAssertNotNil(actual)
        XCTAssert(actual === expected)
    }
    
    func test_indexPath_forItem() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let todo = expectedTodos[1]
        let ip = subject.indexPath(forItem: todo)
        XCTAssertNotNil(ip)
        XCTAssertEqual(ip?.row, 1)
        XCTAssertEqual(ip?.section, 0)
    }
    
    func test_indexPath_forItem_not_found() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let todo = Todo(withTitle: "New one")
        let ip = subject.indexPath(forItem: todo)
        XCTAssertNil(ip)
    }
    
    func test_item_byId() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let expectedTodo = expectedTodos[1]
        expectedTodo.id = 27 // make sure id is unique
        let found = subject.item(byId: expectedTodo.id)
        XCTAssertNotNil(found)
        XCTAssertEqual(found, expectedTodo)
    }
    
    func test_item_byId_not_found() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let found = subject.item(byId: 99)
        XCTAssertNil(found)
    }
    
    /* WARNING:
     Interesting case is here. instead of creating real ViewModel, we create Mock here
     In order to avoid invoking network layer
     It should be ennough for our purposes. We just need to be sure that ViewModel invokes Load data
     */
    func test_download() {
        
        let subject = MockTodosViewModel()
        let expect = expectation(description: "Wait for downloading todos.")
        subject.downloadShouldFail = false
        subject.downloadWasCalled = false
        subject.download { (updatedTodo, error) in
            XCTAssertNil(error)
            XCTAssertTrue(subject.downloadWasCalled)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    func test_update() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let todo = subject.item(forRow: 0) as! MockTodo
        let expect = expectation(description: "Wait for update todo.")
        todo.updateShouldFail = false
        todo.updateWasCalled = false
        subject.update(todo) { (updatedTodo, error) in
            XCTAssertNil(error)
            XCTAssertTrue(todo.updateWasCalled)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func test_delete() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let todo = subject.item(forRow: 0) as! MockTodo
        let expect = expectation(description: "Wait for delete todo.")
        todo.deleteShouldFail = false
        todo.deleteWasCalled = false
        subject.delete(todo) { (updatedTodo, error) in
            XCTAssertNil(error)
            XCTAssertTrue(todo.deleteWasCalled)
            expect.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    
    
    func test_syncCollection_edit() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let expectedModificationType = ModificationType.edit
        let expectedCollectionSize = expectedTodos.count
        let expectedIndex = 1
        let changedTodo = expectedTodos[expectedIndex]
        // do some modification
        let expectedTitle = "Clean code"
        let expectedPrio = 2
        let expectedCategory = "work"
        changedTodo.title = expectedTitle
        changedTodo.category = expectedCategory
        changedTodo.priority = expectedPrio
        // sync with collection - should return expected index!
        guard let ip = subject.syncCollection(with: changedTodo, modificationType:expectedModificationType) else {
            XCTFail("Index path must not be null here")
            return
        }
        // test result
         XCTAssertEqual(ip.row, expectedIndex)
        // test that modified object is in collection
        
        let testedTodo = subject.item(byIndexPath: ip)
        XCTAssertEqual(testedTodo?.title, expectedTitle)
        XCTAssertEqual(testedTodo?.category, expectedCategory)
        XCTAssertEqual(testedTodo?.priority, expectedPrio)
        // collection still should have the same size
        XCTAssertEqual(subject.displayData?.count, expectedCollectionSize)
    }
    
    func test_syncCollection_insert() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let expectedModificationType = ModificationType.insert
        let expectedCollectionSize = subject.displayData!.count + 1
        let addedTodo = Todo(withTitle: "Just added item")
        // do some modification
        let expectedTitle = "Clean code"
        let expectedPrio = 2
        let expectedCategory = "work"
        addedTodo.title = expectedTitle
        addedTodo.category = expectedCategory
        addedTodo.priority = expectedPrio
        // sync with collection - should return expected index!
        guard let ip = subject.syncCollection(with: addedTodo, modificationType:expectedModificationType) else {
            XCTFail("Index path must not be null here")
            return
        }
        // test that modified object is in collection
        let testedTodo = subject.item(byIndexPath: ip)
        XCTAssertEqual(testedTodo?.title, expectedTitle)
        XCTAssertEqual(testedTodo?.category, expectedCategory)
        XCTAssertEqual(testedTodo?.priority, expectedPrio)
        // collection size should increase by adding one extra item
        XCTAssertEqual(subject.displayData?.count, expectedCollectionSize)
    }
    
    func test_syncCollection_delete() {
        let subject = TodosViewModel()
        subject.displayData = expectedTodos
        let expectedModificationType = ModificationType.delete
        let expectedCollectionSize = subject.displayData!.count - 1 // (one less than it was before the test )
        let deletedTodo = expectedTodos[0]
        // sync with collection - should return expected index!
        let ip = subject.syncCollection(with: deletedTodo, modificationType:expectedModificationType)
        XCTAssertNotNil(ip)
         XCTAssertEqual(ip?.row, 0)
        // test that modified object is in collection
        XCTAssertNil(subject.displayData?.index(of: deletedTodo))
        // collection size should increase by adding one extra item
        XCTAssertEqual(subject.displayData?.count, expectedCollectionSize)
    }
    
}


