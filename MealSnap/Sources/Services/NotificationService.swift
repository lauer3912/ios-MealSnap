import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func scheduleMealReminder(mealType: String, time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Log Your \(mealType)"
        content.body = "Don't forget to track your \(mealType.lowercased()) in MealSnap!"
        content.sound = .default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let identifier = "meal_\(mealType.lowercased())"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleWaterReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Stay Hydrated"
        content.body = "Remember to drink water! Tap to log your water intake."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 9

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "water_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleWeeklyReport() {
        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Nutrition Report"
        content.body = "Check out your nutrition summary for this week!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1
        dateComponents.hour = 10

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "weekly_report", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}