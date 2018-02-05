//
//  UITests-complete.swift
//  SimpleTodoUITests
//
//  Created by Alexander Karpenko on 1/31/18.
//  Copyright © 2018 Alexander Karpenko. All rights reserved.
//

import XCTest
class UITestsComplete: XCTestCase {
    
    let newTodoJSON = [
        "id": 8,
        "title": "Do something really useful!",
        "details": "And amazingly interesting!!!",
        "priority": 3,
        "category": "CHALLENGING",
        "completed": false
        ] as [String: AnyObject]
    
    let editedTodoJSON = [
        "id": 8,
        "title": "Do something really useful! NOW",
        "details": "And amazingly interesting!!! And Exciting!",
        "priority": 1,
        "category": "CHALLENGING and urgent",
        "completed": false
        ] as [String: AnyObject]
    
    override func setUp() {
        super.setUp()
        // In UI tests it is usually best to stop NOW when a failure occurs.
        continueAfterFailure = false
        // Set flag that we are in UI testing mode
        let app = XCUIApplication()
        app.launchArguments.append(TestEnvironmentStubInfo.kUseHttpStubs)
        let bundle = Bundle.init(for: UITestsComplete.self)
        //----------------------------------------------------------------------
        //---- ADDING STUBS ----------------------------------------------------
        
        
        //----- (C)reate -------------------------------------------------------
        let createStub = TestEnvironmentStubInfo( method: .create,
                                                  path: "/api/todos",
                                                  statusCode: 201,
                                                  json: newTodoJSON)
        app.launchEnvironment[createStub.key] = createStub.value
        //----- (R)ead ---------------------------------------------------------
        if let readStub = TestEnvironmentStubInfo( method: .read,
                                                    path: "/api/todos",
                                                    statusCode: 200,
                                                    fileName: "getTodos",
                                                    bundle: bundle) {
            app.launchEnvironment[readStub.key] = readStub.value
        }
        //----- (U)pdate -------------------------------------------------------
        let updateStub = TestEnvironmentStubInfo( method: .update,
                                                 path: "/api/todos/8",
                                                 statusCode: 200,
                                                 json: editedTodoJSON)
        app.launchEnvironment[updateStub.key] = updateStub.value
        
        //----- (D)elete -------------------------------------------------------
        let deleteStub = TestEnvironmentStubInfo( method: .delete,
                                                 path: "/api/todos/8",
                                                 statusCode: 204,
                                                 json: [:])
        app.launchEnvironment[deleteStub.key] = deleteStub.value
        //----------------------------------------------------------------------
        let deleteErrorStub = TestEnvironmentStubInfo( method: .delete,
                                                  path: "/api/todos/4",
                                                  statusCode: 404,
                                                  json: [:])
        app.launchEnvironment[deleteErrorStub.key] = deleteErrorStub.value
        //----------------------------------------------------------------------
        
        
        
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCompleteApp() {
        let app = XCUIApplication()
        let firstCell = app.tables.cells.element(boundBy: 0)
        
        // 1. Test that List controller ========================================
        XCTAssertTrue(app.navigationBars["List"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Refresh"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Add"].exists)

        // Simulate Pull2Refresh
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx:0, dy:0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx:0, dy:6))
        start.press(forDuration: 0, thenDragTo: finish)


        // Test Refresh button
        app.navigationBars["List"].buttons["Refresh"].tap()
        // ---------------------------------------------------------------------


        // 2. Test adding new Todo Item ========================================
        // Not Happy Path ------------------------------------------------------
        app.navigationBars["List"].buttons["Add"].tap()
        // Make sure that editor was pushed
        XCTAssertTrue(app.navigationBars["New"].exists)
        XCTAssertTrue(app.navigationBars["New"].buttons["Done"].exists)
        XCTAssertTrue(app.navigationBars["New"].buttons["Cancel"].exists)
        // Fill fields
        app.textFields["TodoEditorTitleText"].typeText("Do Something Really Evil!")
        app.textFields["TodoEditorDetailsText"].tap()
        app.textFields["TodoEditorDetailsText"].typeText("I'll definitely need a Minion's Army!")
        app.textFields["TodoEditorCategoryText"].tap()
        app.textFields["TodoEditorCategoryText"].typeText("👹 Ha-Ha-Ha")
        app.segmentedControls.buttons["Normal"].tap()
        app.segmentedControls.buttons["Low"].tap()
        app.segmentedControls.buttons["High"].tap()
        // Cancel modification in the editor
        app.navigationBars["New"].buttons["Cancel"].tap()
        // Make sure we returned back to list controller
        XCTAssertTrue(app.navigationBars["List"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Refresh"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Add"].exists)
        // and make sure that new record does not appear
        firstCell.swipeUp() // scroll down to last cell
        XCTAssertFalse(app.tables.cells.staticTexts["Do Something Really Evil!"].exists)

        // Happy Path ----------------------------------------------------------
        app.navigationBars["List"].buttons["Add"].tap()
        app.textFields["TodoEditorTitleText"].typeText("Do something really useful!")
        app.textFields["TodoEditorDetailsText"].tap()
        app.textFields["TodoEditorDetailsText"].typeText("And amazingly interesting!!!")
        app.textFields["TodoEditorCategoryText"].tap()
        app.textFields["TodoEditorCategoryText"].typeText("Challenging")
        app.segmentedControls.buttons["Normal"].tap()
        app.segmentedControls.buttons["High"].tap()
        app.segmentedControls.buttons["Low"].tap()
        // And now Confirm modificatios
        app.navigationBars["New"].buttons["Done"].tap()

        // Make sure we returned back to list controller
        XCTAssertTrue(app.navigationBars["List"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Refresh"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Add"].exists)
        // and make sure that new record APPEARS
        firstCell.swipeUp() // scroll down to last cell
        XCTAssertTrue(app.tables.cells.staticTexts["Do something really useful!"].exists)
        // 2. Test adding new Todo Item ========================================


        // 3. Test Editing Todo Item ===========================================
        // Not happy path ------------------------------------------------------
        app.tables.cells.staticTexts["Do something really useful!"].tap()
        // Make sure that editor was pushed
        XCTAssertTrue(app.navigationBars["#8"].exists)
        XCTAssertTrue(app.navigationBars["#8"].buttons["Done"].exists)
        XCTAssertTrue(app.navigationBars["#8"].buttons["Cancel"].exists)
        // Edit fields
        app.textFields["TodoEditorTitleText"].typeText(" Abra - Shvabra - Kadabra")
        app.textFields["TodoEditorDetailsText"].tap()
        app.textFields["TodoEditorDetailsText"].typeText(" Alohomora")
        app.textFields["TodoEditorCategoryText"].tap()
        app.textFields["TodoEditorCategoryText"].typeText(" ???")
        app.segmentedControls.buttons["Normal"].tap()
        app.segmentedControls.buttons["Low"].tap()
        app.segmentedControls.buttons["High"].tap()
        // Cancel changes
        app.navigationBars["#8"].buttons["Cancel"].tap()
        // Make sure we returned back to the list view
        XCTAssertTrue(app.navigationBars["List"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Refresh"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Add"].exists)
        // and make sure that new record does not appear
        firstCell.swipeUp() // scroll down to last cell
        XCTAssertFalse(app.tables.cells.staticTexts["Do something really useful! Abra - Shvabra - Kadabra"].exists)

        // Happy path ----------------------------------------------------------
        app.tables.cells.staticTexts["Do something really useful!"].tap()
        // Edit fields
        app.textFields["TodoEditorTitleText"].typeText(" NOW")
        app.textFields["TodoEditorDetailsText"].tap()
        app.textFields["TodoEditorDetailsText"].typeText(" And Exciting!")
        app.textFields["TodoEditorCategoryText"].tap()
        app.textFields["TodoEditorCategoryText"].typeText(" and urgent")
        app.segmentedControls.buttons["Low"].tap()
        app.segmentedControls.buttons["High"].tap()
        app.segmentedControls.buttons["Normal"].tap()
        // Confirm update
        app.navigationBars["#8"].buttons["Done"].tap()
        // Make sure we returned back to list controller
        XCTAssertTrue(app.navigationBars["List"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Refresh"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Add"].exists)
        // and make sure that new record does not appear
        firstCell.swipeUp() // scroll down to last cell
        XCTAssertTrue(app.tables.cells.staticTexts["Do something really useful! NOW"].exists)
        // 3. Test Editing Todo Item ===========================================


        // 4. Mark Todo As Done! ===============================================
        app.tables.switches["Do something really useful! NOW, CHALLENGING and urgent"].tap()
        // 4. Mark Todo As Done! ===============================================


        // 5. Delete Todo ======================================================
        // Not happy path ------------------------------------------------------
        // make swipe to Left to reveal delete button
        app.tables.cells.staticTexts["Do something really useful! NOW"].swipeLeft()
        // make sure that Delete button exists
        XCTAssertTrue(app.tables.cells.buttons["Delete"].exists)
        // Tap on delete button
        app.tables.cells.buttons["Delete"].tap()
        // make sure that Confirmation Alert appears
        XCTAssertTrue(app.otherElements["SCLAlertView"].exists)
        // Tap Cancel on Confirmation alert
        app.otherElements["SCLAlertView"].buttons["Cancel"].tap()
        // make sure that we still can see row that we tried to delete
        XCTAssertTrue(app.tables.cells.staticTexts["Do something really useful! NOW"].exists)

        // Happy path ----------------------------------------------------------
        app.tables.cells.staticTexts["Do something really useful! NOW"].swipeLeft()
        app.tables.cells.buttons["Delete"].tap()
        app.otherElements["SCLAlertView"].buttons["Delete"].tap()
        // Make sure we returned back to list controller
        XCTAssertTrue(app.navigationBars["List"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Refresh"].exists)
        XCTAssertTrue(app.navigationBars["List"].buttons["Add"].exists)
        // make sure that we are unable to see deleted row
        XCTAssertFalse(app.tables.cells.staticTexts["Do something really useful! NOW"].exists)
        // 5. Delete Todo ======================================================
        
        // 6. Unsuccessful attempt to Delete Todo. Server returns an error =====
        app.tables.cells.staticTexts["Get car to service"].swipeLeft()
        app.tables.cells.buttons["Delete"].tap()
        app.otherElements["SCLAlertView"].buttons["Delete"].tap()
        XCTAssertTrue(app.otherElements["SCLAlertView"].exists)
        XCTAssertTrue(app.otherElements["SCLAlertView"].buttons["Done"].exists)
        app.otherElements["SCLAlertView"].buttons["Done"].tap()
        // 6. Unsuccessful attempt to Delete Todo. Server returns an error =====
    }
}
