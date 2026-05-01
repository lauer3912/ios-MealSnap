import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    private let mealReminderID = "com.ggsheng.MealSnap.mealReminder"

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        center.requestAuthorization(options: [.alert, .sound]) { granted, _ in DispatchQueue.main.async { completion(granted) } }
    }

    func scheduleMealReminder(at hour: Int = 12) {
        center.removePendingNotificationRequests(withIdentifiers: [mealReminderID])
        let content = UNMutableNotificationContent()
        content.title = "🍽️ MealSnap"
        content.body = "Time to log your meal! Track your nutrition and stay on top of your health goals."
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: DateComponents(hour: hour, minute: 0), repeats: true)
        let request = UNNotificationRequest(identifier: mealReminderID, content: content, trigger: trigger)
        center.add(request) { error in if let e = error { print("Notification error: \(e)") } }
    }

    func cancelAll() { center.removePendingNotificationRequests(withIdentifiers: [mealReminderID]) }
    var isEnabled: Bool { get { UserDefaults.standard.bool(forKey: "MealSnap.notificationsEnabled") } set { UserDefaults.standard.set(newValue, forKey: "MealSnap.notificationsEnabled") } }

    func toggle(enabled: Bool, completion: @escaping (Bool) -> Void) {
        if enabled { requestAuthorization { [weak self] granted in if granted { self?.isEnabled = true; self?.scheduleMealReminder(); completion(true) } else { completion(false) } } }
        else { isEnabled = false; cancelAll(); completion(true) }
    }
    func restoreScheduledNotifications() { if isEnabled { scheduleMealReminder() } }
}
