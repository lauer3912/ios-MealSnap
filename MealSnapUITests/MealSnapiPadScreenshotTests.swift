import XCTest

final class MealSnapiPadScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
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
