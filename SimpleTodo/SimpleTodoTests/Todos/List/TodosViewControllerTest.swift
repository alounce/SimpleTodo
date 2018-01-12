//
//  TodosViewControllerTest.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 1/4/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import XCTest
import Moya
@testable import SimpleTodo

class TodosViewControllerTest: XCTestCase {
    var subject: TodosViewController!
    var mockVM: MockTodosViewModel!
    override func setUp() {
        super.setUp()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        subject = sb.instantiateViewController(withIdentifier: "TodosViewController") as! TodosViewController
        mockVM = MockTodosViewModel()
        subject.viewModel = mockVM
        _ = subject.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_viewDidLoad() {
        XCTAssertNotNil(subject.tableView)
        XCTAssertNotNil(subject.tableView.dataSource)
        XCTAssertTrue(mockVM.downloadWasCalled)
    }
    
    func test_loadData() {
        // clear mock status
        mockVM.downloadWasCalled = false
        mockVM.downloadShouldFail = false
        XCTAssertFalse(mockVM.downloadWasCalled)
        subject.loadData(self)
        // test that method was called
        XCTAssertTrue(mockVM.downloadWasCalled)
        // make sure it was successful
        XCTAssertNil(mockVM.lastError)
    }
    
    func test_loadData_failure() {
        // clear mock status
        mockVM.downloadWasCalled = false
        // but now load should fail
        mockVM.downloadShouldFail = true
        XCTAssertFalse(mockVM.downloadWasCalled)
        subject.loadData(self)
        // test that method was called
        XCTAssertTrue(mockVM.downloadWasCalled)
        // make sure it failed
        XCTAssertNotNil(mockVM.lastError)
    }
    
    func test_tableView_cellForRowAt() {
        let ip = IndexPath(row: 1, section: 0)
        let cell = subject.tableView(subject.tableView, cellForRowAt: ip)
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell as? TodoTableViewCell)
    }
    
    func test_todoCell_didChangeCompletion_success() {
        let ip = IndexPath(row: 1, section: 0)
        let todo = mockVM.item(byIndexPath: ip)!
        let cell = subject.tableView.cellForRow(at:ip) as! TodoTableViewCell
        cell.configure(id: todo.id, title: todo.title, category: todo.category, priority: todo.priority, completed: todo.completed)
        mockVM.updateWasCalled = false
        mockVM.updateShouldFail = false
        XCTAssertFalse(mockVM.updateWasCalled)
        subject.todoCell(cell, didChangeCompletion: true)
        XCTAssertTrue(mockVM.updateWasCalled)
        XCTAssertNil(mockVM.lastError)
    }
    
    func test_todoCell_didChangeCompletion_failure() {
        let ip = IndexPath(row: 1, section: 0)
        let todo = mockVM.item(byIndexPath: ip)!
        let cell = subject.tableView.cellForRow(at:ip) as! TodoTableViewCell
        cell.configure(id: todo.id, title: todo.title, category: todo.category, priority: todo.priority, completed: todo.completed)
        mockVM.updateShouldFail = true
        mockVM.updateWasCalled = false
        XCTAssertFalse(mockVM.updateWasCalled)
        subject.todoCell(cell, didChangeCompletion: true)
        XCTAssertTrue(mockVM.updateWasCalled)
        XCTAssertNotNil(mockVM.lastError)
    }
    
    func test_addNew() {
        // simutate tap on todo cell - for editing
        subject.onAddNew(self)
        //XCTAssertTrue(mockVM.updateWasCalled)
    }
    
    func test_edit() {
        // simutate tap on todo cell - for editing
        let ip = IndexPath(row: 1, section: 0)
        subject.tableView(subject.tableView, didSelectRowAt: ip)
        //XCTAssertTrue(mockVM.updateWasCalled)
    }
    
    func test_delete() {
        let ip = IndexPath(row: 1, section: 0)
        let todo = mockVM.item(byIndexPath: ip)!
        subject.delete(todo)
    }
        
    func test_tableView_editActionsForRowAt() {
        // simutate swipe on todo cell - for deleting
        let ip = IndexPath(row: 1, section: 0)
        let actions = subject.tableView(subject.tableView, editActionsForRowAt:ip)
        XCTAssertNotNil(actions)
        XCTAssertEqual(actions?.count, 1)
        XCTAssertEqual(actions?[0].title, "Delete")
        XCTAssertEqual(actions?[0].style, .destructive)
    }
    
    func test_editor_didChange() {
        // setup editor controller with added item
        let editor = TodoEditorViewController()
        var todo = Todo(withTitle: "Just added")
        editor.configure(withDelegate: subject, todo: todo, modificationType: .insert)
        // invoke delegate methdo
        subject.editor(editor, didChange: todo)
        
        // the same but edit action
        todo = subject.viewModel.item(forRow: 1, inGroup: 0)!
        editor.configure(withDelegate: subject, todo: todo, modificationType: .edit)
        subject.editor(editor, didChange: todo)
        
        // the same but delete action
        editor.configure(withDelegate: subject, todo: todo, modificationType: .delete)
        subject.editor(editor, didChange: todo)
    }
    
    func test_editor_didChange_when_no_changes() {
        // setup editor controller
        let editor = TodoEditorViewController()
        // invoke delegate method
        subject.editor(editor, didChange: nil)
    }
    
    
}
