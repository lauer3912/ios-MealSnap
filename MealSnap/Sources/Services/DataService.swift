import Foundation

final class DataService {
    static let shared = DataService()

    private let nutritionDataKey = "nutrition_data"
    private let goalsKey = "nutrition_goals"
    private let recipesKey = "recipes"
    private let mealPlansKey = "meal_plans"

    private init() {
        loadData()
    }

    var dailyNutrition: [DailyNutrition] = []
    var nutritionGoals: NutritionGoals = .default
    var recipes: [Recipe] = []
    var mealPlans: [MealPlan] = []

    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: nutritionDataKey),
           let nutrition = try? JSONDecoder().decode([DailyNutrition].self, from: data) {
            dailyNutrition = nutrition
        }

        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let goals = try? JSONDecoder().decode(NutritionGoals.self, from: data) {
            nutritionGoals = goals
        }

        if let data = UserDefaults.standard.data(forKey: recipesKey),
           let savedRecipes = try? JSONDecoder().decode([Recipe].self, from: data) {
            recipes = savedRecipes
        }

        if let data = UserDefaults.standard.data(forKey: mealPlansKey),
           let plans = try? JSONDecoder().decode([MealPlan].self, from: data) {
            mealPlans = plans
        }
    }

    func saveData() {
        if let data = try? JSONEncoder().encode(dailyNutrition) {
            UserDefaults.standard.set(data, forKey: nutritionDataKey)
        }

        if let data = try? JSONEncoder().encode(nutritionGoals) {
            UserDefaults.standard.set(data, forKey: goalsKey)
        }

        if let data = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(data, forKey: recipesKey)
        }

        if let data = try? JSONEncoder().encode(mealPlans) {
            UserDefaults.standard.set(data, forKey: mealPlansKey)
        }
    }

    func addFood(_ food: FoodItem) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let index = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: today) }) 
            dailyNutrition[index].meals.append(food)
        } else {
            var newDay = DailyNutrition.today
            newDay.meals.append(food)
            dailyNutrition.insert(newDay, at: 0)
        }

        saveData()
    }

    func removeFood(at index: Int, from day: Date) {
        let calendar = Calendar.current

        if let dayIndex = dailyNutrition.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: day) }) 
            guard index < dailyNutrition[dayIndex].meals.count else { return }
            dailyNutrition[dayIndex].meals.remove(at: index)
            saveData()
        }
    }

    func getTodayNutrition() -> DailyNutrition {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let todayData = dailyNutrition.first(where: { calendar.isDate($0.date, inSameDayAs: today) }) 
            return todayData
        }

        return DailyNutrition.today
    }

    func updateGoals(_ goals: NutritionGoals) {
        nutritionGoals = goals
        saveData()
    }

    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveData()
    }

    func toggleRecipeFavorite(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index].isFavorite.toggle()
            saveData()
        }
    }

    func addMealPlan(_ plan: MealPlan) {
        mealPlans.append(plan)
        saveData()
    }

    func getWeeklyReport() -> WeeklyReport {
        let calendar = Calendar.current
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now)!

        let weekData = dailyNutrition.filter { $0.date >= weekStart }

        guard !weekData.isEmpty else {
            return WeeklyReport(
                weekStartDate: weekStart,
                averageCalories: 0,
                averageProtein: 0,
                averageCarbs: 0,
                averageFat: 0,
                totalMeals: 0,
                bestDay: nil,
                worstDay: nil,
                calorieTrend: [],
                macroDistribution: [:]
            )
        }

        let totalCalories = weekData.reduce(0) { $0 + $1.totalCalories }
        let totalProtein = weekData.reduce(0.0) { $0 + $1.totalProtein }
        let totalCarbs = weekData.reduce(0.0) { $0 + $1.totalCarbs }
        let totalFat = weekData.reduce(0.0) { $0 + $1.totalFat }
        let totalMeals = weekData.reduce(0) { $0 + $1.meals.count }

        let sortedByCalories = weekData.sorted { $0.totalCalories < $1.totalCalories }

        return WeeklyReport(
            weekStartDate: weekStart,
            averageCalories: totalCalories / max(weekData.count, 1),
            averageProtein: totalProtein / Double(max(weekData.count, 1)),
            averageCarbs: totalCarbs / Double(max(weekData.count, 1)),
            averageFat: totalFat / Double(max(weekData.count, 1)),
            totalMeals: totalMeals,
            bestDay: sortedByCalories.last?.date,
            worstDay: sortedByCalories.first?.date,
            calorieTrend: weekData.map { $0.totalCalories },
            macroDistribution: [
                "Protein": totalProtein,
                "Carbs": totalCarbs,
                "Fat": totalFat
            ]
        )
    }

    func exportData() -> String {
        var csv = "Date,MealType,Food,Calories,Protein,Carbs,Fat,Fiber,Sugar,Sodium\n"

        for day in dailyNutrition {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"

            for meal in day.meals {
                csv += "\(formatter.string(from: day.date)),"
                csv += "\(meal.mealType.rawValue),"
                csv += "\"\(meal.name)\","
                csv += "\(meal.calories),"
                csv += "\(Int(meal.protein)),"
                csv += "\(Int(meal.carbs)),"
                csv += "\(Int(meal.fat)),"
                csv += "\(Int(meal.fiber)),"
                csv += "\(Int(meal.sugar)),"
                csv += "\(Int(meal.sodium))\n"
            }
        }

        return csv
    }
}