import Foundation
import UserNotifications

// MARK: - Notification Manager
// Handles scheduling and managing event reminder notifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Request Permission
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("Failed to request notification authorization: \(error)")
            return false
        }
    }
    
    // MARK: - Schedule Event Reminder
    
    func scheduleEventReminder(for event: Event) async {
        // Make sure we have a time and reminder setting
        guard let reminderMinutes = event.reminderMinutesBefore,
              let eventTime = event.time else {
            return
        }
        
        // Calculate reminder time
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: event.date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: eventTime)
        
        var eventDateTime = DateComponents()
        eventDateTime.year = dateComponents.year
        eventDateTime.month = dateComponents.month
        eventDateTime.day = dateComponents.day
        eventDateTime.hour = timeComponents.hour
        eventDateTime.minute = timeComponents.minute
        
        guard let fullEventDate = calendar.date(from: eventDateTime) else {
            return
        }
        
        let reminderDate = calendar.date(byAdding: .minute, value: -reminderMinutes, to: fullEventDate)
        
        guard let reminderDate = reminderDate else {
            return
        }
        
        // Don't schedule notifications in the past
        guard reminderDate > Date() else {
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Event Reminder"
        content.body = event.title
        if let notes = event.notes {
            content.subtitle = notes
        }
        content.sound = .default
        
        // Create trigger
        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        // Create request
        let identifier = event.notificationIdentifier ?? UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Schedule notification
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ Scheduled reminder for '\(event.title)' at \(reminderDate)")
        } catch {
            print("❌ Failed to schedule notification: \(error)")
        }
    }
    
    // MARK: - Cancel Event Reminder
    
    func cancelEventReminder(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🗑️ Cancelled reminder with identifier: \(identifier)")
    }
    
    // MARK: - Cancel All Reminders
    
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Check Pending Notifications
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    // MARK: - Habit Reminders
    
    func scheduleHabitReminders(for habit: Habit) async -> [String] {
        // First, cancel any existing reminders for this habit
        cancelHabitReminders(identifiers: habit.notificationIdentifiers)
        
        guard habit.reminderEnabled, let reminderTime = habit.reminderTime else {
            return []
        }
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        var newIdentifiers: [String] = []
        
        // Schedule based on frequency
        switch habit.frequency {
        case .daily:
            // Schedule for every day
            for weekday in 1...7 {
                let identifier = await scheduleHabitNotification(
                    habitName: habit.name,
                    hour: timeComponents.hour ?? 9,
                    minute: timeComponents.minute ?? 0,
                    weekday: weekday
                )
                if let identifier = identifier {
                    newIdentifiers.append(identifier)
                }
            }
            
        case .specificDays:
            // Schedule only for selected days
            for weekday in habit.selectedDays {
                let identifier = await scheduleHabitNotification(
                    habitName: habit.name,
                    hour: timeComponents.hour ?? 9,
                    minute: timeComponents.minute ?? 0,
                    weekday: weekday
                )
                if let identifier = identifier {
                    newIdentifiers.append(identifier)
                }
            }
            
        case .weekly:
            // Schedule for first selected day (or Sunday if none selected)
            let weekday = habit.selectedDays.min() ?? 1
            let identifier = await scheduleHabitNotification(
                habitName: habit.name,
                hour: timeComponents.hour ?? 9,
                minute: timeComponents.minute ?? 0,
                weekday: weekday
            )
            if let identifier = identifier {
                newIdentifiers.append(identifier)
            }
        }
        
        print("✅ Scheduled \(newIdentifiers.count) reminders for '\(habit.name)'")
        return newIdentifiers
    }
    
    private func scheduleHabitNotification(habitName: String, hour: Int, minute: Int, weekday: Int) async -> String? {
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to do: \(habitName)"
        content.sound = .default
        content.categoryIdentifier = "HABIT_REMINDER"
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.weekday = weekday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = "habit_\(UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            return identifier
        } catch {
            print("❌ Failed to schedule habit notification: \(error)")
            return nil
        }
    }
    
    func cancelHabitReminders(identifiers: [String]) {
        guard !identifiers.isEmpty else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("🗑️ Cancelled \(identifiers.count) habit reminders")
    }
}
