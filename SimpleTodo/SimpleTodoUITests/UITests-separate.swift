//
//  SimpleTodoUITests.swift
//  SimpleTodoUITests
//
//  Created by Alexander Karpenko on 1/11/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import XCTest
class SimpleTodoUITests: XCTestCase {
    
    let newTodoJSON = [
        "id": 24,
        "title": "Do something really useful!",
        "details": "And amazingly interesting!!!",
        "priority": 1,
        "category": "CHALLENGING",
        "completed": false
        ] as [String: AnyObject]
    
    let editedTodoJSON = [
        "id": 4,
        "title": "Get car to service. IMMEDIATELLY",
        "details": "left moving light is not working. also check the engine!",
        "priority": 1,
        "category": "car",
        "completed": false
        ] as [String: AnyObject]
    
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // Set flag that we are in UI testing mode
        let app = XCUIApplication()
        app.launchArguments.append(TestEnvironmentStubInfo.kUseHttpStubs)
        let bundle = Bundle.init(for: SimpleTodoUITests.self)
        //----------------------------------------------------------------------
        //---- ADDING STUBS ----------------------------------------------------
        
        
        //----- (C)reate -------------------------------------------------------
        let createStub = TestEnvironmentStubInfo( method: .create,
                                                 path: "/api/todos",
                                                 statusCode: 200,
                                                 json: newTodoJSON)
        app.launchEnvironment[createStub.key] = createStub.value
        //----- (R)ead ---------------------------------------------------------
        if let stubInfo1 = TestEnvironmentStubInfo( method: .read,
                                                   path: "/api/todos",
                                                   statusCode: 200,
                                                   fileName: "getTodos",
                                                   bundle: bundle) {
            app.launchEnvironment[stubInfo1.key] = stubInfo1.value
        }
        //----- (U)pdate -------------------------------------------------------
        let stubInfo2 = TestEnvironmentStubInfo( method: .update,
                                                path: "/api/todos/4",
                                                statusCode: 200,
                                                json: editedTodoJSON)
        app.launchEnvironment[stubInfo2.key] = stubInfo2.value
        
        //----- (D)elete -------------------------------------------------------
        let stubInfo3 = TestEnvironmentStubInfo( method: .delete,
                                                 path: "/api/todos/3",
                                                 statusCode: 204,
                                                 json: [:])
        app.launchEnvironment[stubInfo3.key] = stubInfo3.value
        //----------------------------------------------------------------------
        app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddTodoThenCancel() {
        let app = XCUIApplication()
        
        //Tap at Add Todo button
        app.navigationBars["List"].buttons["Add"].tap()
        
        // Make sure that editor was pushed
        let navigationBar = app.navigationBars["New"]
        XCTAssertTrue(navigationBar.exists)
        XCTAssertTrue(navigationBar.buttons["Done"].exists)
        XCTAssertTrue(navigationBar.buttons["Cancel"].exists)
        
        // Fill the Title
        app.textFields["TodoEditorTitleText"].typeText("Do something really evil!")
        
        // Fill the Details field
        let todoeditordetailstextTextField = app.textFields["TodoEditorDetailsText"]
        todoeditordetailstextTextField.tap()
        todoeditordetailstextTextField.tap()
        todoeditordetailstextTextField.typeText("I'll definitely need the Minion's Army!")
        
        // Fill the Category field
        let todoeditorcategorytextTextField = app.textFields["TodoEditorCategoryText"]
        todoeditorcategorytextTextField.tap()
        todoeditorcategorytextTextField.typeText("👹 Ha-Ha-Ha")
        
        app.segmentedControls.buttons["Normal"].tap()
        app.segmentedControls.buttons["High"].tap()
        app.segmentedControls.buttons["Low"].tap()
        
        navigationBar.buttons["Cancel"].tap()
        XCTAssertFalse(app.tables.cells.staticTexts["Do something really evil!"].exists)
        
    }
    
    func testAddTodoThenConfirm() {
        let app = XCUIApplication()
        
        //Tap at Add Todo button
        app.navigationBars["List"].buttons["Add"].tap()
        
        // Make sure that editor was pushed
        let navigationBar = app.navigationBars["New"]
        XCTAssertTrue(navigationBar.exists)
        XCTAssertTrue(navigationBar.buttons["Done"].exists)
        XCTAssertTrue(navigationBar.buttons["Cancel"].exists)
        
        // Fill the Title
        app.textFields["TodoEditorTitleText"].typeText("Do something really useful!")
        
        // Fill the Details field
        let todoeditordetailstextTextField = app.textFields["TodoEditorDetailsText"]
        todoeditordetailstextTextField.tap()
        todoeditordetailstextTextField.tap()
        todoeditordetailstextTextField.typeText("And amazingly interesting!!!")
        
        // Fill the Category field
        let todoeditorcategorytextTextField = app.textFields["TodoEditorCategoryText"]
        todoeditorcategorytextTextField.tap()
        todoeditorcategorytextTextField.typeText("CHALLENGING")
        
        app.segmentedControls.buttons["Low"].tap()
        app.segmentedControls.buttons["Normal"].tap()
        app.segmentedControls.buttons["High"].tap()
        
        navigationBar.buttons["Done"].tap()
        let table = app.tables.element(boundBy: 0)
        let firstCell = table.cells.element(boundBy: 0)
        firstCell.swipeUp()
        
        XCTAssertTrue(app.tables.cells.staticTexts["Do something really useful!"].exists)
    }
    
    
    func testEditTodoThenCancel() {
        
        let app = XCUIApplication()
        
        // Tap at cell
        let getCarToServiceStaticText = app.tables/*@START_MENU_TOKEN@*/.cells.staticTexts["Get car to service"]/*[[".cells.staticTexts[\"Get car to service\"]",".staticTexts[\"Get car to service\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        getCarToServiceStaticText.tap()
        
        // Make sure that editor was pushed
        let navigationBar = app.navigationBars["#4"]
        XCTAssertTrue(navigationBar.exists)
        
        // Modify the Title field
        let titleField = app.textFields["TodoEditorTitleText"]
        titleField.tap()
        titleField.typeText(" abra shwabra cadabra")
        
        // Modify the Details field
        let detailsField = app.textFields["TodoEditorDetailsText"]
        detailsField.tap()
        detailsField.typeText(" sim salabim")
        
        // Increase the Priority
        let lowButton = app.segmentedControls.buttons["Low"]
        lowButton.tap()
        
        // Cancel editor
        navigationBar.buttons["Cancel"].tap()
        
        // Make sure that data was not changed
        XCTAssertTrue(app.tables.cells.staticTexts["Get car to service"].exists)
    }
    
    func testEditTodoThenConfirm() {
        
        let app = XCUIApplication()
        
        // Tap at cell
        let getCarToServiceStaticText = app.tables/*@START_MENU_TOKEN@*/.cells.staticTexts["Get car to service"]/*[[".cells.staticTexts[\"Get car to service\"]",".staticTexts[\"Get car to service\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        getCarToServiceStaticText.tap()
        
        // Make sure that editor was pushed
        let navigationBar = app.navigationBars["#4"]
        XCTAssertTrue(navigationBar.exists)
        
        // Modify the Title field
        let titleField = app.textFields["TodoEditorTitleText"]
        titleField.tap()
        titleField.typeText(". IMMEDIATELLY")
        
        // Modify the Details field
        let detailsField = app.textFields["TodoEditorDetailsText"]
        detailsField.tap()
        detailsField.typeText(". also check the engine!")
        
        // Increase the Priority
        let highButton = app/*@START_MENU_TOKEN@*/.segmentedControls.buttons["High"]/*[[".segmentedControls.buttons[\"High\"]",".buttons[\"High\"]"],[[[-1,1],[-1,0]]],[1]]@END_MENU_TOKEN@*/
        highButton.tap()
        
        // confirm changes
        navigationBar.buttons["Done"].tap()
        
        // Make sure that data was changed
        XCTAssertFalse(app.tables.cells.staticTexts["Get car to service"].exists)
        XCTAssertTrue(app.tables.cells.staticTexts["Get car to service. IMMEDIATELLY"].exists)
    }
    

    
    func testDelete() {
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        // make sure that Delete button is not visible in normal mode
        XCTAssertFalse(tablesQuery.buttons["Delete"].exists)
        
        // make swipe to Left to reveal delete button
        tablesQuery.cells.staticTexts["Plug SwiftLint to Street Genie"].swipeLeft()
        
        // make sure that Delete button exists
        XCTAssertTrue(tablesQuery.buttons["Delete"].exists)
        
        // perform click on it
        tablesQuery.buttons["Delete"].tap()
        
        
        // tap on Cancel button in the Alert
        XCTAssertTrue(app.otherElements["SCLAlertView"].exists)
        app.otherElements["SCLAlertView"].buttons["Cancel"].tap()
        
        // make sure that we still can see row that we tried to delete
        XCTAssertTrue(tablesQuery.cells.staticTexts["Plug SwiftLint to Street Genie"].exists)
        
        // repeat the same but now confirm on delete
        tablesQuery.cells.staticTexts["Plug SwiftLint to Street Genie"].swipeLeft()
        tablesQuery.buttons["Delete"].tap()
        app.otherElements["SCLAlertView"].buttons["Delete"].tap()
        
        // make sure that we cannot see row anymore
        XCTAssertFalse(tablesQuery.cells.staticTexts["Plug SwiftLint to Street Genie"].exists)
        
        // Now hit refresh button, since we are using stubs deleted row appeaers again
        //app.navigationBars["List"].buttons["Refresh"].tap()
        
        // or make pull 2 refresh action
        let table = app.tables.element(boundBy: 0)
        let firstCell = table.cells.element(boundBy: 0)
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx:0, dy:0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx:0, dy:6))
            start.press(forDuration: 0, thenDragTo: finish)
            
        XCTAssertTrue(tablesQuery.cells.staticTexts["Plug SwiftLint to Street Genie"].exists)
    }
 
    
}
