//
//  NocturnalUITests.swift
//  NocturnalUITests
//
//  Created by Boray Chen on 2022/7/21.
//

import XCTest

class NocturnalUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        sleep(3)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddEvent() throws {
        // UI tests must launch the application that they test.
        
        let app = XCUIApplication()
        let addEventButton = app.buttons["add"]
//        XCTAssertTrue(addEventButton.exists)
        addEventButton.tap()
        
        let uploadNewEventImageElement = app.tables.otherElements["Upload New Event Image"]
        XCTAssertTrue(uploadNewEventImageElement.exists)
        uploadNewEventImageElement.staticTexts["Upload New Event Image"].tap()
        
        let uploadNewVideoImageElement = uploadNewEventImageElement.staticTexts["Upload New Event Video (Optional)"]
        XCTAssertTrue(uploadNewVideoImageElement.exists)
        uploadNewVideoImageElement.tap()
        
        let backButton = app.navigationBars["Nocturnal.AddEvent"].buttons["Back"]
        XCTAssertTrue(backButton.exists)
        backButton.tap()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
