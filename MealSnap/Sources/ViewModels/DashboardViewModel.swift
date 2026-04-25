import Foundation
import Combine

final class DashboardViewModel: ObservableObject {
    @Published var todayNutrition: DailyNutrition
    @Published var calorieProgress: Double = 0
    @Published var macroProgress: (protein: Double, carbs: Double, fat: Double) = (0, 0, 0)
    @Published var recentMeals: [FoodItem] = []
    @Published var weeklyCalories: [Int] = []

    private let dataService = DataService.shared

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        else if hour < 17 { return "Good Afternoon" }
        else { return "Good Evening" }
    }

    var remainingCalories: Int {
        dataService.nutritionGoals.dailyCalories - todayNutrition.totalCalories
    }

    var calorieStatusText: String {
        if remainingCalories > 0 {
            return "\(remainingCalories) cal remaining"
        } else if remainingCalories == 0 {
            return "Goal reached!"
        } else {
            return "\(abs(remainingCalories)) cal over goal"
        }
    }

    init() {
        todayNutrition = dataService.getTodayNutrition()
        updateData()
    }

    func updateData() {
        todayNutrition = dataService.getTodayNutrition()

        let goals = dataService.nutritionGoals
        calorieProgress = min(Double(todayNutrition.totalCalories) / Double(goals.dailyCalories), 1.0)

        macroProgress = (
            protein: min(todayNutrition.totalProtein / goals.dailyProtein, 1.0),
            carbs: min(todayNutrition.totalCarbs / goals.dailyCarbs, 1.0),
            fat: min(todayNutrition.totalFat / goals.dailyFat, 1.0)
        )

        recentMeals = Array(todayNutrition.meals.suffix(5).reversed())
        weeklyCalories = calculateWeeklyCalories()
    }

    private func calculateWeeklyCalories() -> [Int] {
        let calendar = Calendar.current
        var result: [Int] = []

        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            if let dayData = dataService.dailyNutrition.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                result.append(dayData.totalCalories)
            } else {
                result.append(0)
            }
        }

        return result.reversed()
    }

    func getMealsByType(_ type: FoodItem.MealType) -> [FoodItem] {
        todayNutrition.meals.filter { $0.mealType == type }
    }

    func getCaloriesForMeal(_ type: FoodItem.MealType) -> Int {
        getMealsByType(type).reduce(0) { $0 + $1.calories }
    }
}