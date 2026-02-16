import Foundation
import Combine
import AuthenticationServices

/// Manages integration with Google Calendar API
@MainActor
class GoogleCalendarManager: NSObject, ObservableObject {
    static let shared = GoogleCalendarManager()
    
    @Published var isAuthenticated = false
    @Published var syncEnabled = false
    @Published var userEmail: String?
    
    private let baseURL = "https://www.googleapis.com/calendar/v3"
    private var accessToken: String?
    private var refreshToken: String?
    
    // Google OAuth Configuration
    // NOTE: You'll need to set these up in Google Cloud Console
    private let clientID = "657493089268-qmc643b5jlhet355mg2ktnu0o6b0a404.apps.googleusercontent.com" // Replace with your Google OAuth Client ID
    private let redirectURI = "com.googleusercontent.apps.657493089268:/oauth2redirect/google"
    
    // Key for storing tokens
    private let accessTokenKey = "googleCalendarAccessToken"
    private let refreshTokenKey = "googleCalendarRefreshToken"
    private let userEmailKey = "googleCalendarUserEmail"
    private let syncEnabledKey = "googleCalendarSyncEnabled"
    
    private override init() {
        super.init()
        loadStoredCredentials()
    }
    
    // MARK: - Authentication
    
    /// Load stored credentials from UserDefaults
    private func loadStoredCredentials() {
        accessToken = UserDefaults.standard.string(forKey: accessTokenKey)
        refreshToken = UserDefaults.standard.string(forKey: refreshTokenKey)
        userEmail = UserDefaults.standard.string(forKey: userEmailKey)
        syncEnabled = UserDefaults.standard.bool(forKey: syncEnabledKey)
        isAuthenticated = accessToken != nil
    }
    
    /// Save credentials to UserDefaults
    private func saveCredentials(accessToken: String, refreshToken: String?, email: String?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.userEmail = email
        
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        if let refreshToken = refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        }
        if let email = email {
            UserDefaults.standard.set(email, forKey: userEmailKey)
        }
        
        isAuthenticated = true
    }
    
    /// Clear stored credentials
    func signOut() {
        accessToken = nil
        refreshToken = nil
        userEmail = nil
        isAuthenticated = false
        syncEnabled = false
        
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)
        UserDefaults.standard.set(false, forKey: syncEnabledKey)
    }
    
    /// Enable or disable sync
    func setSyncEnabled(_ enabled: Bool) {
        syncEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: syncEnabledKey)
    }
    
    /// Authenticate with Google using ASWebAuthenticationSession
    func authenticate() async throws {
        let scopes = [
            "https://www.googleapis.com/auth/calendar",
            "https://www.googleapis.com/auth/calendar.events"
        ]
        
        let scopeString = scopes.joined(separator: "%20")
        
        let authURL = "https://accounts.google.com/o/oauth2/v2/auth?" +
            "client_id=\(clientID)" +
            "&redirect_uri=\(redirectURI)" +
            "&response_type=code" +
            "&scope=\(scopeString)" +
            "&access_type=offline" +
            "&prompt=consent"
        
        guard let url = URL(string: authURL) else {
            throw GoogleCalendarError.invalidURL
        }
        
        // Use ASWebAuthenticationSession for OAuth
        let callbackURL = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<URL, Error>) in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: redirectURI.components(separatedBy: ":").first
            ) { callbackURL, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let callbackURL = callbackURL {
                    continuation.resume(returning: callbackURL)
                } else {
                    continuation.resume(throwing: GoogleCalendarError.authenticationFailed)
                }
            }
            
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = false
            session.start()
        }
        
        // Extract authorization code from callback URL
        guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
            throw GoogleCalendarError.authenticationFailed
        }
        
        // Exchange code for tokens
        try await exchangeCodeForToken(code: code)
    }
    
    /// Exchange authorization code for access token
    private func exchangeCodeForToken(code: String) async throws {
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "code=\(code)" +
            "&client_id=\(clientID)" +
            "&redirect_uri=\(redirectURI)" +
            "&grant_type=authorization_code"
        
        request.httpBody = body.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GoogleCalendarError.tokenExchangeFailed
        }
        
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        // Get user email
        let email = try await fetchUserEmail(accessToken: tokenResponse.accessToken)
        
        saveCredentials(
            accessToken: tokenResponse.accessToken,
            refreshToken: tokenResponse.refreshToken,
            email: email
        )
    }
    
    /// Fetch user's email address
    private func fetchUserEmail(accessToken: String) async throws -> String {
        let url = URL(string: "https://www.googleapis.com/oauth2/v2/userinfo")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let userInfo = try JSONDecoder().decode(UserInfo.self, from: data)
        return userInfo.email
    }
    
    /// Refresh access token if expired
    private func refreshAccessToken() async throws {
        guard let refreshToken = refreshToken else {
            throw GoogleCalendarError.notAuthenticated
        }
        
        let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "refresh_token=\(refreshToken)" +
            "&client_id=\(clientID)" +
            "&grant_type=refresh_token"
        
        request.httpBody = body.data(using: .utf8)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
        
        self.accessToken = tokenResponse.accessToken
        UserDefaults.standard.set(tokenResponse.accessToken, forKey: accessTokenKey)
    }
    
    // MARK: - Calendar Operations
    
    /// Create an authenticated request
    private func createAuthenticatedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(accessToken ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    /// Fetch events from Google Calendar
    func fetchEvents(from startDate: Date, to endDate: Date) async throws -> [GoogleCalendarEvent] {
        guard isAuthenticated, let accessToken = accessToken else {
            throw GoogleCalendarError.notAuthenticated
        }
        
        guard syncEnabled else {
            return []
        }
        
        let formatter = ISO8601DateFormatter()
        let timeMin = formatter.string(from: startDate)
        let timeMax = formatter.string(from: endDate)
        
        var components = URLComponents(string: "\(baseURL)/calendars/primary/events")!
        components.queryItems = [
            URLQueryItem(name: "timeMin", value: timeMin),
            URLQueryItem(name: "timeMax", value: timeMax),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime")
        ]
        
        guard let url = components.url else {
            throw GoogleCalendarError.invalidURL
        }
        
        let request = createAuthenticatedRequest(url: url)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Check for 401 (unauthorized) and refresh token if needed
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                try await refreshAccessToken()
                // Retry request
                return try await fetchEvents(from: startDate, to: endDate)
            }
            
            let eventsResponse = try JSONDecoder().decode(GoogleCalendarEventsResponse.self, from: data)
            return eventsResponse.items
        } catch {
            throw GoogleCalendarError.fetchFailed
        }
    }
    
    /// Create event in Google Calendar
    func createEvent(_ event: Event) async throws -> String {
        guard isAuthenticated, syncEnabled else {
            throw GoogleCalendarError.notAuthenticated
        }
        
        let url = URL(string: "\(baseURL)/calendars/primary/events")!
        var request = createAuthenticatedRequest(url: url, method: "POST")
        
        let googleEvent = convertToGoogleEvent(event)
        request.httpBody = try JSONEncoder().encode(googleEvent)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Check for 401 and retry
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            try await refreshAccessToken()
            return try await createEvent(event)
        }
        
        let createdEvent = try JSONDecoder().decode(GoogleCalendarEvent.self, from: data)
        return createdEvent.id
    }
    
    /// Update event in Google Calendar
    func updateEvent(_ event: Event, googleEventId: String) async throws {
        guard isAuthenticated, syncEnabled else {
            throw GoogleCalendarError.notAuthenticated
        }
        
        let url = URL(string: "\(baseURL)/calendars/primary/events/\(googleEventId)")!
        var request = createAuthenticatedRequest(url: url, method: "PUT")
        
        let googleEvent = convertToGoogleEvent(event)
        request.httpBody = try JSONEncoder().encode(googleEvent)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Check for 401 and retry
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            try await refreshAccessToken()
            try await updateEvent(event, googleEventId: googleEventId)
        }
    }
    
    /// Delete event from Google Calendar
    func deleteEvent(googleEventId: String) async throws {
        guard isAuthenticated, syncEnabled else {
            throw GoogleCalendarError.notAuthenticated
        }
        
        let url = URL(string: "\(baseURL)/calendars/primary/events/\(googleEventId)")!
        let request = createAuthenticatedRequest(url: url, method: "DELETE")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        // Check for 401 and retry
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
            try await refreshAccessToken()
            try await deleteEvent(googleEventId: googleEventId)
        }
    }
    
    // MARK: - Event Conversion
    
    /// Convert app Event to Google Calendar event
    private func convertToGoogleEvent(_ event: Event) -> GoogleCalendarEventCreate {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        
        let start: GoogleEventDateTime
        let end: GoogleEventDateTime
        
        if event.isAllDay {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let dateString = dateFormatter.string(from: event.date)
            
            start = GoogleEventDateTime(date: dateString, dateTime: nil, timeZone: nil)
            
            // All-day events end on the next day
            let endDate = Calendar.current.date(byAdding: .day, value: 1, to: event.date) ?? event.date
            let endDateString = dateFormatter.string(from: endDate)
            end = GoogleEventDateTime(date: endDateString, dateTime: nil, timeZone: nil)
        } else {
            let startDateTime = formatter.string(from: event.eventDateTime)
            let endDateTime = formatter.string(from: event.eventEndDateTime ?? Calendar.current.date(byAdding: .hour, value: 1, to: event.eventDateTime) ?? event.eventDateTime)
            
            start = GoogleEventDateTime(date: nil, dateTime: startDateTime, timeZone: TimeZone.current.identifier)
            end = GoogleEventDateTime(date: nil, dateTime: endDateTime, timeZone: TimeZone.current.identifier)
        }
        
        var recurrence: [String]?
        if let rule = event.recurrenceRule {
            recurrence = [convertToGoogleRecurrence(rule, endDate: event.recurrenceEndDate)]
        }
        
        var reminders: GoogleEventReminders?
        if let reminderMinutes = event.reminderMinutesBefore {
            reminders = GoogleEventReminders(
                useDefault: false,
                overrides: [GoogleEventReminder(method: "popup", minutes: reminderMinutes)]
            )
        }
        
        return GoogleCalendarEventCreate(
            summary: event.title,
            description: event.notes,
            start: start,
            end: end,
            recurrence: recurrence,
            reminders: reminders
        )
    }
    
    /// Convert app RecurrenceRule to Google Calendar RRULE format
    private func convertToGoogleRecurrence(_ rule: Event.RecurrenceRule, endDate: Date?) -> String {
        let freq: String
        let interval: Int
        
        switch rule {
        case .daily:
            freq = "DAILY"
            interval = 1
        case .weekly:
            freq = "WEEKLY"
            interval = 1
        case .biweekly:
            freq = "WEEKLY"
            interval = 2
        case .monthly:
            freq = "MONTHLY"
            interval = 1
        case .yearly:
            freq = "YEARLY"
            interval = 1
        }
        
        var rrule = "RRULE:FREQ=\(freq);INTERVAL=\(interval)"
        
        if let endDate = endDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            formatter.timeZone = TimeZone(identifier: "UTC")
            let untilString = formatter.string(from: endDate)
            rrule += ";UNTIL=\(untilString)"
        }
        
        return rrule
    }
    
    /// Convert Google Calendar event to app Event
    func convertToAppEvent(_ googleEvent: GoogleCalendarEvent) -> Event {
        let isAllDay = googleEvent.start.date != nil
        
        let date: Date
        let time: Date?
        let endTime: Date?
        
        if isAllDay {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            date = dateFormatter.date(from: googleEvent.start.date ?? "") ?? Date()
            time = nil
            endTime = nil
        } else {
            let formatter = ISO8601DateFormatter()
            date = formatter.date(from: googleEvent.start.dateTime ?? "") ?? Date()
            time = date
            endTime = formatter.date(from: googleEvent.end?.dateTime ?? "")
        }
        
        var recurrenceRule: Event.RecurrenceRule?
        if let recurrence = googleEvent.recurrence?.first {
            recurrenceRule = parseGoogleRecurrence(recurrence)
        }
        
        return Event(
            title: googleEvent.summary ?? "Untitled",
            date: date,
            time: time,
            endTime: endTime,
            isAllDay: isAllDay,
            notes: googleEvent.description,
            recurrenceRule: recurrenceRule
        )
    }
    
    /// Parse Google RRULE to app RecurrenceRule
    private func parseGoogleRecurrence(_ rrule: String) -> Event.RecurrenceRule? {
        if rrule.contains("FREQ=DAILY") {
            return .daily
        } else if rrule.contains("FREQ=WEEKLY") {
            if rrule.contains("INTERVAL=2") {
                return .biweekly
            }
            return .weekly
        } else if rrule.contains("FREQ=MONTHLY") {
            return .monthly
        } else if rrule.contains("FREQ=YEARLY") {
            return .yearly
        }
        return nil
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension GoogleCalendarManager: ASWebAuthenticationPresentationContextProviding {
    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        // Return the key window
        return ASPresentationAnchor()
    }
}

// MARK: - Models

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
    let expiresIn: Int
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
}

struct UserInfo: Codable {
    let email: String
}

struct GoogleCalendarEventsResponse: Codable {
    let items: [GoogleCalendarEvent]
}

struct GoogleCalendarEvent: Codable {
    let id: String
    let summary: String?
    let description: String?
    let start: GoogleEventDateTime
    let end: GoogleEventDateTime?
    let recurrence: [String]?
}

struct GoogleCalendarEventCreate: Codable {
    let summary: String
    let description: String?
    let start: GoogleEventDateTime
    let end: GoogleEventDateTime
    let recurrence: [String]?
    let reminders: GoogleEventReminders?
}

struct GoogleEventDateTime: Codable {
    let date: String?
    let dateTime: String?
    let timeZone: String?
}

struct GoogleEventReminders: Codable {
    let useDefault: Bool
    let overrides: [GoogleEventReminder]?
}

struct GoogleEventReminder: Codable {
    let method: String
    let minutes: Int
}

// MARK: - Errors

enum GoogleCalendarError: LocalizedError {
    case notAuthenticated
    case invalidURL
    case authenticationFailed
    case tokenExchangeFailed
    case fetchFailed
    case createFailed
    case updateFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Not authenticated with Google Calendar"
        case .invalidURL:
            return "Invalid URL"
        case .authenticationFailed:
            return "Google authentication failed"
        case .tokenExchangeFailed:
            return "Failed to exchange authorization code for token"
        case .fetchFailed:
            return "Failed to fetch events from Google Calendar"
        case .createFailed:
            return "Failed to create event in Google Calendar"
        case .updateFailed:
            return "Failed to update event in Google Calendar"
        case .deleteFailed:
            return "Failed to delete event from Google Calendar"
        }
    }
}
