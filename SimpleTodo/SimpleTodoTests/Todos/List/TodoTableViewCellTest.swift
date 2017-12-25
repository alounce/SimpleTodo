//
//  TodoTableViewCellTest.swift
//  SimpleTodoTests
//
//  Created by Alexander Karpenko on 1/4/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import XCTest
@testable import SimpleTodo

class TodoTableViewCellTest: XCTestCase {
    var todosVC: TodosViewController!
    var mockVM: MockTodosViewModel!
    
    override func setUp() {
        super.setUp()
        let sb = UIStoryboard(name: "Main", bundle: nil)
        todosVC = sb.instantiateViewController(withIdentifier: "TodosViewController") as! TodosViewController
        mockVM = MockTodosViewModel()
        todosVC.viewModel = mockVM
        _ = todosVC.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_outlets() {
        let ip = IndexPath(row: 1, section: 0)
        let cell = todosVC.tableView(todosVC.tableView, cellForRowAt: ip) as! TodoTableViewCell
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell.titleLabel)
        XCTAssertNotNil(cell.descriptionLabel)
        XCTAssertNotNil(cell.completedSwitch)
        XCTAssertNotNil(cell.priorityMarker)
        //XCTAssertNotNil(cell.notBoundControl)
    }
    
    func test_configure() {
        let ip = IndexPath(row: 1, section: 0)
        let cell = todosVC.tableView(todosVC.tableView, cellForRowAt: ip) as! TodoTableViewCell
        XCTAssertNotNil(cell)
        cell.configure(id: 10, title: "test", category: "cat", priority: 1, completed: false)
        XCTAssertEqual(cell.titleLabel?.text, "test")
        XCTAssertEqual(cell.descriptionLabel?.text, "cat")
        XCTAssertEqual(cell.completedSwitch?.isOn, false)
    }
    
    func test_configure_priority() {
        let ip = IndexPath(row: 1, section: 0)
        let cell = todosVC.tableView(todosVC.tableView, cellForRowAt: ip) as! TodoTableViewCell
        XCTAssertNotNil(cell)
        cell.configure(id: 10, title: "test", category: "cat", priority: 1, completed: false)
        XCTAssertEqual(cell.priorityMarker?.backgroundColor, .red)
        cell.configure(id: 10, title: "test", category: "cat", priority: 2, completed: false)
        XCTAssertEqual(cell.priorityMarker?.backgroundColor, .orange)
        cell.configure(id: 10, title: "test", category: "cat", priority: 3, completed: false)
        XCTAssertEqual(cell.priorityMarker?.backgroundColor, .green)
        cell.configure(id: 10, title: "test", category: "cat", priority: 4, completed: false)
        XCTAssertEqual(cell.priorityMarker?.backgroundColor, .blue)
    }
    
    func test_onChangeCompletion() {
        let ip = IndexPath(row: 1, section: 0)
        let cell = todosVC.tableView(todosVC.tableView, cellForRowAt: ip) as! TodoTableViewCell
        XCTAssertNotNil(cell)
        mockVM.updateWasCalled = false
        XCTAssertFalse(mockVM.updateWasCalled)
        cell.onChangeCompletion(cell.completedSwitch)
        XCTAssertTrue(mockVM.updateWasCalled)
    }
    
}
