import XCTest
@testable import MealSnap

final class MealSnapTests: XCTestCase {

    func testFoodItemCreation() {
        let food = FoodItem(
            id: UUID(),
            name: "Test Food",
            calories: 100,
            protein: 10,
            carbs: 20,
            fat: 5,
            fiber: 3,
            sugar: 5,
            sodium: 200,
            servingSize: "100g",
            servingGrams: 100,
            barcode: "123456789",
            mealType: .lunch,
            date: Date()
        )
        XCTAssertEqual(food.name, "Test Food")
        XCTAssertEqual(food.calories, 100)
        XCTAssertEqual(food.protein, 10)
        XCTAssertEqual(food.carbs, 20)
        XCTAssertEqual(food.mealType, .lunch)
    }

    func testMealType() {
        XCTAssertEqual(MealType.allCases.count, 4)
        XCTAssertEqual(MealType.breakfast.rawValue, "Breakfast")
        XCTAssertEqual(MealType.lunch.rawValue, "Lunch")
        XCTAssertEqual(MealType.dinner.rawValue, "Dinner")
        XCTAssertEqual(MealType.snack.rawValue, "Snack")
    }

    func testFoodItemMacroSummary() {
        let food = FoodItem.sample
        XCTAssertFalse(food.macroSummary.isEmpty)
        XCTAssertTrue(food.macroSummary.contains("P:"))
        XCTAssertTrue(food.macroSummary.contains("C:"))
        XCTAssertTrue(food.macroSummary.contains("F:"))
    }

    func testFoodItemSample() {
        let sample = FoodItem.sample
        XCTAssertEqual(sample.name, "Grilled Chicken Salad")
        XCTAssertEqual(sample.calories, 350)
        XCTAssertEqual(sample.protein, 30)
    }
}