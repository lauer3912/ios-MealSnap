import Foundation

struct FoodItem: Codable, Identifiable {
    let id: UUID
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var sodium: Double
    var servingSize: String
    var servingGrams: Double
    var barcode: String?
    var photoData: Data?
    var mealType: MealType
    var date: Date

    enum MealType: String, Codable, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
    }

    var macroSummary: String {
        "P: \(Int(protein))g | C: \(Int(carbs))g | F: \(Int(fat))g"
    }

    static var sample: FoodItem {
        FoodItem(
            id: UUID(),
            name: "Grilled Chicken Salad",
            calories: 350,
            protein: 30,
            carbs: 15,
            fat: 18,
            fiber: 5,
            sugar: 8,
            sodium: 450,
            servingSize: "1 serving",
            servingGrams: 250,
            barcode: nil,
            photoData: nil,
            mealType: .lunch,
            date: Date()
        )
    }
}

struct DailyNutrition: Codable {
    var date: Date
    var targetCalories: Int
    var targetProtein: Double
    var targetCarbs: Double
    var targetFat: Double
    var meals: [FoodItem]

    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.calories }
    }

    var totalProtein: Double {
        meals.reduce(0) { $0 + $1.protein }
    }

    var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbs }
    }

    var totalFat: Double {
        meals.reduce(0) { $0 + $1.fat }
    }

    var calorieProgress: Double {
        guard targetCalories > 0 else { return 0 }
        return min(Double(totalCalories) / Double(targetCalories), 1.0)
    }

    static var today: DailyNutrition {
        DailyNutrition(
            date: Date(),
            targetCalories: 2000,
            targetProtein: 50,
            targetCarbs: 250,
            targetFat: 65,
            meals: []
        )
    }
}

struct NutritionGoals: Codable {
    var dailyCalories: Int
    var dailyProtein: Double
    var dailyCarbs: Double
    var dailyFat: Double
    var waterIntake: Int
    var mealReminders: Bool

    static var `default`: NutritionGoals {
        NutritionGoals(
            dailyCalories: 2000,
            dailyProtein: 50,
            dailyCarbs: 250,
            dailyFat: 65,
            waterIntake: 8,
            mealReminders: true
        )
    }
}

struct MealPlan: Codable, Identifiable {
    let id: UUID
    var name: String
    var calories: Int
    var meals: [PlannedMeal]
    var isActive: Bool
}

struct PlannedMeal: Codable, Identifiable {
    let id: UUID
    var name: String
    var calories: Int
    var time: Date
    var foods: [String]
}

struct Recipe: Codable, Identifiable {
    let id: UUID
    var name: String
    var ingredients: [String]
    var instructions: [String]
    var calories: Int
    var prepTime: Int
    var cookTime: Int
    var servings: Int
    var imageData: Data?
    var isFavorite: Bool

    var totalTime: Int {
        prepTime + cookTime
    }
}

struct WeeklyReport {
    var weekStartDate: Date
    var averageCalories: Int
    var averageProtein: Double
    var averageCarbs: Double
    var averageFat: Double
    var totalMeals: Int
    var bestDay: Date?
    var worstDay: Date?
    var calorieTrend: [Int]
    var macroDistribution: [String: Double]
}

struct BarcodeProduct {
    var barcode: String
    var name: String
    var brand: String?
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var servingSize: String
}