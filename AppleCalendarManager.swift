import Foundation
import EventKit
import Combine

/// Manages integration between the app and Apple Calendar using EventKit
@MainActor
class AppleCalendarManager: ObservableObject {
    static let shared = AppleCalendarManager()
    
    private let eventStore = EKEventStore()
    
    @Published var isAuthorized = false
    @Published var syncEnabled = false
    
    // Key for storing EventKit identifier mappings
    private let eventMappingKey = "eventKitIdentifierMapping"
    
    private init() {
        checkAuthorizationStatus()
        loadSyncPreference()
    }
    
    // MARK: - Authorization
    
    /// Check current authorization status
    private func checkAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: .event)
        isAuthorized = (status == .fullAccess || status == .authorized)
    }
    
    /// Request access to user's calendar
    func requestAccess() async -> Bool {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            isAuthorized = granted
            return granted
        } catch {
            print("Calendar access error: \(error.localizedDescription)")
            isAuthorized = false
            return false
        }
    }
    
    // MARK: - Sync Preference
    
    /// Load sync preference from UserDefaults
    private func loadSyncPreference() {
        syncEnabled = UserDefaults.standard.bool(forKey: "appleCalendarSyncEnabled")
    }
    
    /// Enable or disable calendar sync
    func setSyncEnabled(_ enabled: Bool) {
        syncEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "appleCalendarSyncEnabled")
    }
    
    // MARK: - Event Mapping
    
    /// Store mapping between app Event ID and EventKit identifier
    private func saveEventMapping(appEventId: UUID, ekIdentifier: String) {
        var mappings = getEventMappings()
        mappings[appEventId.uuidString] = ekIdentifier
        
        if let data = try? JSONEncoder().encode(mappings) {
            UserDefaults.standard.set(data, forKey: eventMappingKey)
        }
    }
    
    /// Retrieve EventKit identifier for an app event
    private func getEKIdentifier(for appEventId: UUID) -> String? {
        let mappings = getEventMappings()
        return mappings[appEventId.uuidString]
    }
    
    /// Remove mapping when event is deleted
    private func removeEventMapping(appEventId: UUID) {
        var mappings = getEventMappings()
        mappings.removeValue(forKey: appEventId.uuidString)
        
        if let data = try? JSONEncoder().encode(mappings) {
            UserDefaults.standard.set(data, forKey: eventMappingKey)
        }
    }
    
    /// Get all event mappings
    private func getEventMappings() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: eventMappingKey),
              let mappings = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return mappings
    }
    
    // MARK: - Fetch Events from Apple Calendar
    
    /// Fetch events from Apple Calendar for a date range
    func fetchEvents(from startDate: Date, to endDate: Date) -> [EKEvent] {
        guard isAuthorized else { return [] }
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil // nil means all calendars
        )
        
        return eventStore.events(matching: predicate)
    }
    
    /// Convert EKEvent to app's Event model
    func convertToAppEvent(_ ekEvent: EKEvent) -> Event {
        var event = Event(
            title: ekEvent.title ?? "Untitled",
            date: ekEvent.startDate,
            time: ekEvent.isAllDay ? nil : ekEvent.startDate,
            endTime: ekEvent.isAllDay ? nil : ekEvent.endDate,
            isAllDay: ekEvent.isAllDay,
            notes: ekEvent.notes
        )
        
        // Check for recurrence
        if let recurrenceRule = ekEvent.recurrenceRules?.first {
            event.recurrenceRule = convertRecurrenceRule(recurrenceRule)
        }
        
        return event
    }
    
    /// Convert EKRecurrenceRule to app's RecurrenceRule
    private func convertRecurrenceRule(_ ekRule: EKRecurrenceRule) -> Event.RecurrenceRule? {
        switch ekRule.frequency {
        case .daily:
            return .daily
        case .weekly:
            return ekRule.interval == 2 ? .biweekly : .weekly
        case .monthly:
            return .monthly
        case .yearly:
            return .yearly
        @unknown default:
            return nil
        }
    }
    
    // MARK: - Import Events from Apple Calendar
    
    /// Import events from Apple Calendar into the app
    func importEvents(from startDate: Date, to endDate: Date) -> [Event] {
        let ekEvents = fetchEvents(from: startDate, to: endDate)
        return ekEvents.map { convertToAppEvent($0) }
    }
    
    // MARK: - Sync App Event to Apple Calendar
    
    /// Create or update an event in Apple Calendar
    func syncEventToAppleCalendar(_ event: Event) async throws {
        guard isAuthorized else {
            throw CalendarError.notAuthorized
        }
        
        guard syncEnabled else {
            return // Sync is disabled
        }
        
        // Check if event already exists in Apple Calendar
        if let ekIdentifier = getEKIdentifier(for: event.id),
           let existingEvent = eventStore.event(withIdentifier: ekIdentifier) {
            // Update existing event
            try updateEKEvent(existingEvent, with: event)
        } else {
            // Create new event
            try createEKEvent(from: event)
        }
    }
    
    /// Create a new event in Apple Calendar
    private func createEKEvent(from event: Event) throws {
        let ekEvent = EKEvent(eventStore: eventStore)
        
        ekEvent.title = event.title
        ekEvent.notes = event.notes
        ekEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        // Set dates
        if event.isAllDay {
            ekEvent.isAllDay = true
            ekEvent.startDate = Calendar.current.startOfDay(for: event.date)
            ekEvent.endDate = Calendar.current.date(byAdding: .day, value: 1, to: ekEvent.startDate) ?? ekEvent.startDate
        } else {
            ekEvent.isAllDay = false
            ekEvent.startDate = event.eventDateTime
            ekEvent.endDate = event.eventEndDateTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: event.eventDateTime) ?? event.eventDateTime
        }
        
        // Add recurrence rule if applicable
        if let recurrenceRule = event.recurrenceRule {
            let ekRule = createEKRecurrenceRule(from: recurrenceRule, endDate: event.recurrenceEndDate)
            ekEvent.addRecurrenceRule(ekRule)
        }
        
        // Add alarm if reminder is set
        if let reminderMinutes = event.reminderMinutesBefore {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60))
            ekEvent.addAlarm(alarm)
        }
        
        // Save to calendar
        try eventStore.save(ekEvent, span: .thisEvent)
        
        // Store mapping
        saveEventMapping(appEventId: event.id, ekIdentifier: ekEvent.eventIdentifier)
    }
    
    /// Update an existing event in Apple Calendar
    private func updateEKEvent(_ ekEvent: EKEvent, with event: Event) throws {
        ekEvent.title = event.title
        ekEvent.notes = event.notes
        
        // Update dates
        if event.isAllDay {
            ekEvent.isAllDay = true
            ekEvent.startDate = Calendar.current.startOfDay(for: event.date)
            ekEvent.endDate = Calendar.current.date(byAdding: .day, value: 1, to: ekEvent.startDate) ?? ekEvent.startDate
        } else {
            ekEvent.isAllDay = false
            ekEvent.startDate = event.eventDateTime
            ekEvent.endDate = event.eventEndDateTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: event.eventDateTime) ?? event.eventDateTime
        }
        
        // Update recurrence rule
        ekEvent.recurrenceRules?.forEach { ekEvent.removeRecurrenceRule($0) }
        if let recurrenceRule = event.recurrenceRule {
            let ekRule = createEKRecurrenceRule(from: recurrenceRule, endDate: event.recurrenceEndDate)
            ekEvent.addRecurrenceRule(ekRule)
        }
        
        // Update alarms
        ekEvent.alarms?.forEach { ekEvent.removeAlarm($0) }
        if let reminderMinutes = event.reminderMinutesBefore {
            let alarm = EKAlarm(relativeOffset: TimeInterval(-reminderMinutes * 60))
            ekEvent.addAlarm(alarm)
        }
        
        // Save changes
        try eventStore.save(ekEvent, span: .futureEvents)
    }
    
    /// Create EKRecurrenceRule from app's RecurrenceRule
    private func createEKRecurrenceRule(from rule: Event.RecurrenceRule, endDate: Date?) -> EKRecurrenceRule {
        let frequency: EKRecurrenceFrequency
        let interval: Int
        
        switch rule {
        case .daily:
            frequency = .daily
            interval = 1
        case .weekly:
            frequency = .weekly
            interval = 1
        case .biweekly:
            frequency = .weekly
            interval = 2
        case .monthly:
            frequency = .monthly
            interval = 1
        case .yearly:
            frequency = .yearly
            interval = 1
        }
        
        let end: EKRecurrenceEnd?
        if let endDate = endDate {
            end = EKRecurrenceEnd(end: endDate)
        } else {
            end = Optional<EKRecurrenceEnd>.none
        }
        
        return EKRecurrenceRule(
            recurrenceWith: frequency,
            interval: interval,
            end: end
        )
    }
    
    // MARK: - Delete Event from Apple Calendar
    
    /// Delete an event from Apple Calendar
    func deleteEventFromAppleCalendar(_ event: Event) async throws {
        guard isAuthorized else {
            throw CalendarError.notAuthorized
        }
        
        guard syncEnabled else {
            return // Sync is disabled
        }
        
        guard let ekIdentifier = getEKIdentifier(for: event.id),
              let ekEvent = eventStore.event(withIdentifier: ekIdentifier) else {
            return // Event doesn't exist in Apple Calendar
        }
        
        try eventStore.remove(ekEvent, span: .futureEvents)
        removeEventMapping(appEventId: event.id)
    }
    
    // MARK: - Bulk Sync
    
    /// Sync all app events to Apple Calendar
    func syncAllEventsToAppleCalendar(_ events: [Event]) async throws {
        guard isAuthorized && syncEnabled else { return }
        
        for event in events {
            try await syncEventToAppleCalendar(event)
        }
    }
}

// MARK: - Calendar Errors

enum CalendarError: LocalizedError {
    case notAuthorized
    case eventNotFound
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Calendar access not authorized"
        case .eventNotFound:
            return "Event not found in calendar"
        case .saveFailed:
            return "Failed to save event to calendar"
        }
    }
}
