import XCTest
import UIKit

final class MealSnapScreenshotTests: XCTestCase {

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
        let id = getDeviceId()
        try? data.write(to: URL(fileURLWithPath: "/tmp/MealSnap_\(id)_\(name).png"))
    }

    func getDeviceId() -> String {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return "iPad_129"
        } else {
            let h = app.windows.firstMatch.frame.height
            // iPhone 16 Pro Max: 1320x2868 @3x = 440x956 pt
            // iPhone 16 Plus: 1290x2796 @3x = 430x932 pt
            // iPhone 16: 1170x2532 @3x = 390x844 pt
            if h >= 900 {
                return "iPhone_69"  // Pro Max ~956pt
            } else if h >= 850 {
                return "iPhone_65"  // Plus ~932pt
            } else {
                return "iPhone_61"  // Standard ~844pt
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
