import XCTest
import UIKit

final class MealSnapScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownError() throws {
        app = nil
    }

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        let id = getDeviceId()
        try? data.write(to: URL(fileURLWithPath: "/tmp/MealSnap_\(id)_\(name).png"))
    }

    func getDeviceId() -> String {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "iPad_129"
        } else {
            let h = app.windows.firstMatch.frame.height
            if h >= 2800 {
                return "iPhone_69"  // 1320x2868 or similar
            } else if h >= 2500 {
                return "iPhone_65"  // 1290x2796 or similar
            } else {
                return "iPhone_61"  // 1170x2532 or similar
            }
        }
    }

    func test_01_Dashboard() throws {
        ss("portrait_01_Dashboard")
    }

    func test_02_Search() throws {
        if app.tabBars.buttons["Search"].exists {
            app.tabBars.buttons["Search"].tap()
            sleep(1)
        }
        ss("portrait_02_Search")
    }

    func test_03_Recipes() throws {
        if app.tabBars.buttons["Recipes"].exists {
            app.tabBars.buttons["Recipes"].tap()
            sleep(1)
        }
        ss("portrait_03_Recipes")
    }

    func test_04_Settings() throws {
        if app.tabBars.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
            sleep(1)
        }
        ss("portrait_04_Settings")
    }

    func test_05_AddFood() throws {
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            sleep(1)
        }
        ss("portrait_05_AddFood")
    }
}

final class MealSnapiPadScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownError() throws {
        app = nil
    }

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "/tmp/MealSnap_iPad_129_\(name).png"))
    }

    func test_01_Dashboard_iPad() throws {
        ss("portrait_01_Dashboard")
    }

    func test_02_Search_iPad() throws {
        if app.tabBars.buttons["Search"].exists {
            app.tabBars.buttons["Search"].tap()
            sleep(1)
        }
        ss("portrait_02_Search")
    }

    func test_03_Recipes_iPad() throws {
        if app.tabBars.buttons["Recipes"].exists {
            app.tabBars.buttons["Recipes"].tap()
            sleep(1)
        }
        ss("portrait_03_Recipes")
    }

    func test_04_Settings_iPad() throws {
        if app.tabBars.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
            sleep(1)
        }
        ss("portrait_04_Settings")
    }
}
