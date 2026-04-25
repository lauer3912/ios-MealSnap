import XCTest

final class MealSnapScreenshotTests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func ss(_ name: String) {
        let data = app.windows.firstMatch.screenshot().pngRepresentation
        try? data.write(to: URL(fileURLWithPath: "/tmp/\(name).png"))
    }

    func test_01_Dashboard() throws {
        ss("MealSnap_iPhone_69_portrait_01_Dashboard")
    }

    func test_02_Search() throws {
        if app.tabBars.buttons["Search"].exists {
            app.tabBars.buttons["Search"].tap()
            sleep(1)
        }
        ss("MealSnap_iPhone_69_portrait_02_Search")
    }

    func test_03_Recipes() throws {
        if app.tabBars.buttons["Recipes"].exists {
            app.tabBars.buttons["Recipes"].tap()
            sleep(1)
        }
        ss("MealSnap_iPhone_69_portrait_03_Recipes")
    }

    func test_04_Settings() throws {
        if app.tabBars.buttons["Settings"].exists {
            app.tabBars.buttons["Settings"].tap()
            sleep(1)
        }
        ss("MealSnap_iPhone_69_portrait_04_Settings")
    }

    func test_05_AddFood() throws {
        if app.buttons["plus.circle.fill"].exists {
            app.buttons["plus.circle.fill"].tap()
            sleep(1)
        }
        ss("MealSnap_iPhone_69_portrait_05_AddFood")
    }
}
