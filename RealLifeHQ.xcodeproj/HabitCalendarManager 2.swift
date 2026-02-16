import EventKit
import Foundation

// MARK: - Habit Calendar Manager
// Handles adding habits as recurring events to the system calendar

@MainActor
class HabitCalendarManager {
    static let shared = HabitCalendarManager()
    private let eventStore = EKEventStore()
    
    private init() {}
    
    // MARK: - Authorization
    
    /// Request calendar access permission
    func requestCalendarAccess() async -> Bool {
        if #available(iOS 17.0, *) {
            do {
                return try await eventStore.requestFullAccessToEvents()
            } catch {
                print("Calendar permission error: \(error)")
                return false
            }
        } else {
            return await withCheckedContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        print("Calendar permission error: \(error)")
                    }
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    /// Check current calendar authorization status
    func authorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - Add Habit to Calendar
    
    /// Add habit as recurring events to calendar
    func addHabitToCalendar(habit: Habit) async -> [String] {
        // Check permission
        guard await requestCalendarAccess() else {
            print("Calendar access denied")
            return []
        }
        
        guard let reminderTime = habit.reminderTime else {
            print("No reminder time set for habit")
            return []
        }
        
        var eventIdentifiers: [String] = []
        
        // Create events based on frequency
        switch habit.frequency {
        case .daily:
            // Create single recurring daily event
            if let eventId = await createRecurringEvent(
                title: habit.name,
                time: reminderTime,
                duration: habit.calendarDuration,
                recurrenceRule: .daily,
                daysOfWeek: nil
            ) {
                eventIdentifiers.append(eventId)
            }
            
        case .specificDays, .weekly:
            // Create recurring events for specific days
            if let eventId = await createRecurringEvent(
                title: habit.name,
                time: reminderTime,
                duration: habit.calendarDuration,
                recurrenceRule: .weekly,
                daysOfWeek: Array(habit.selectedDays).sorted()
            ) {
                eventIdentifiers.append(eventId)
            }
        }
        
        return eventIdentifiers
    }
    
    // MARK: - Create Recurring Event
    
    private func createRecurringEvent(
        title: String,
        time: Date,
        duration: Int,
        recurrenceRule: EKRecurrenceFrequency,
        daysOfWeek: [Int]?
    ) async -> String? {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        // Set start time (combine today's date with the habit's time)
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        let now = Date()
        let startDate = calendar.date(bySettingHour: timeComponents.hour ?? 9,
                                      minute: timeComponents.minute ?? 0,
                                      second: 0,
                                      of: now) ?? now
        
        event.startDate = startDate
        event.endDate = startDate.addingTimeInterval(TimeInterval(duration * 60))
        
        // Create recurrence rule
        var daysOfWeekForRule: [EKRecurrenceDayOfWeek]?
        if let days = daysOfWeek {
            daysOfWeekForRule = days.map { dayNumber in
                // Convert our day format (1=Sunday) to EKWeekday
                let weekday = EKWeekday(rawValue: dayNumber) ?? .sunday
                return EKRecurrenceDayOfWeek(weekday)
            }
        }
        
        let recurrence = EKRecurrenceRule(
            recurrenceWith: recurrenceRule,
            interval: 1,
            daysOfTheWeek: daysOfWeekForRule,
            daysOfTheMonth: nil,
            monthsOfTheYear: nil,
            weeksOfTheYear: nil,
            daysOfTheYear: nil,
            setPositions: nil,
            end: nil  // No end date (recurring indefinitely)
        )
        
        event.addRecurrenceRule(recurrence)
        
        // Add notes
        event.notes = "🎯 Habit Tracker: \(title)"
        
        // Save event
        do {
            try eventStore.save(event, span: .futureEvents)
            return event.eventIdentifier
        } catch {
            print("Error saving event to calendar: \(error)")
            return nil
        }
    }
    
    // MARK: - Remove Habit from Calendar
    
    /// Remove habit events from calendar
    func removeHabitFromCalendar(eventIdentifiers: [String]) async -> Bool {
        guard await requestCalendarAccess() else {
            return false
        }
        
        var success = true
        
        for identifier in eventIdentifiers {
            if let event = eventStore.event(withIdentifier: identifier) {
                do {
                    try eventStore.remove(event, span: .futureEvents)
                } catch {
                    print("Error removing event from calendar: \(error)")
                    success = false
                }
            }
        }
        
        return success
    }
    
    // MARK: - Update Habit in Calendar
    
    /// Update existing calendar events for a habit
    func updateHabitInCalendar(habit: Habit, oldEventIds: [String]) async -> [String] {
        // Remove old events
        _ = await removeHabitFromCalendar(eventIdentifiers: oldEventIds)
        
        // Add new events if still enabled
        if habit.addToCalendar {
            return await addHabitToCalendar(habit: habit)
        }
        
        return []
    }
}
