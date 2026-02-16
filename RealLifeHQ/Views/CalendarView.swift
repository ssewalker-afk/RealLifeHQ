import SwiftUI

// MARK: - Calendar View
// Manage and view all your events and appointments in an hourly daily view

struct CalendarView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject private var calendarManager = AppleCalendarManager.shared
    // Note: Uncomment when GoogleCalendarManager.swift is added to your target
    // @ObservedObject private var googleManager = GoogleCalendarManager.shared
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var showingDatePicker = false
    @State private var showingReminderWizard = false
    
    private let hours = Array(0...23)
    
    var body: some View {
        VStack(spacing: 0) {
            // Date selector header
            dateHeaderView
            
            Divider()
            
            // Hourly schedule view with adaptive width
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // All-day events section
                        if !allDayEvents.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("All-Day Events")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                ForEach(allDayEvents) { event in
                                    HourlyEventCard(
                                        event: event,
                                        onDelete: { deleteEvent(event) }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 8)
                            .background(themeManager.currentTheme.cardColor.opacity(0.5))
                            
                            Divider()
                        }
                        
                        ForEach(hours, id: \.self) { hour in
                            HourRowView(
                                hour: hour,
                                events: eventsForHour(hour),
                                selectedDate: selectedDate,
                                onDeleteEvent: { event in
                                    deleteEvent(event)
                                }
                            )
                            .id(hour)
                        }
                    }
                }
                .onAppear {
                    // Scroll to current hour on appear
                    let currentHour = Calendar.current.component(.hour, from: Date())
                    if Calendar.current.isDateInToday(selectedDate) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo(currentHour, anchor: .top)
                            }
                        }
                    }
                }
                .onChange(of: selectedDate) { _, _ in
                    // Scroll to current hour when date changes to today
                    if Calendar.current.isDateInToday(selectedDate) {
                        let currentHour = Calendar.current.component(.hour, from: Date())
                        withAnimation {
                            proxy.scrollTo(currentHour, anchor: .top)
                        }
                    }
                }
            }
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                // Sync status indicator
                HStack(spacing: 8) {
                    if calendarManager.syncEnabled {
                        HStack(spacing: 4) {
                            Image(systemName: "applelogo")
                                .font(.caption2)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(6)
                    }
                    
                    // Note: Uncomment when GoogleCalendarManager is available
                    /*
                    if googleManager.syncEnabled && googleManager.isAuthenticated {
                        HStack(spacing: 4) {
                            Image(systemName: "g.circle.fill")
                                .font(.caption2)
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                    */
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddEvent = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(selectedDate: selectedDate)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate)
        }
        .sheet(isPresented: $showingReminderWizard) {
            ReminderWizardView()
        }
        .overlay(alignment: .bottomTrailing) {
            // Floating Reminder Wizard Button
            Button {
                showingReminderWizard = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Life Reminders")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [
                            themeManager.currentTheme.primaryColor,
                            themeManager.currentTheme.accentColor
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(25)
                .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding()
        }
    }
    
    private var dateHeaderView: some View {
        HStack {
            // Previous day button
            Button {
                withAnimation {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            Spacer()
            
            // Date display - tappable to show date picker
            Button {
                showingDatePicker = true
            } label: {
                VStack(spacing: 4) {
                    Text(selectedDate.formatted(.dateTime.weekday(.wide)))
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Next day button
            Button {
                withAnimation {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            // Today button
            Button {
                withAnimation {
                    selectedDate = Date()
                }
            } label: {
                Text("Today")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(themeManager.currentTheme.accentColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
    }
    
    private func eventsForHour(_ hour: Int) -> [Event] {
        eventsForSelectedDate.filter { event in
            // Don't show all-day events in hourly slots
            if event.isAllDay {
                return false
            }
            
            guard let eventTime = event.time else { return false }
            let eventHour = Calendar.current.component(.hour, from: eventTime)
            return eventHour == hour
        }
    }
    
    private var allDayEvents: [Event] {
        eventsForSelectedDate.filter { $0.isAllDay }
    }
    
    private var eventsForSelectedDate: [Event] {
        dataManager.events.filter { event in
            Calendar.current.isDate(event.date, inSameDayAs: selectedDate)
        }.sorted { $0.eventDateTime < $1.eventDateTime }
    }
    
    private func deleteEvent(_ event: Event) {
        // Cancel notification if exists
        if let notificationId = event.notificationIdentifier {
            NotificationManager.shared.cancelEventReminder(identifier: notificationId)
        }
        dataManager.deleteEvent(event)
    }
}

// MARK: - Hour Row View

struct HourRowView: View {
    let hour: Int
    let events: [Event]
    let selectedDate: Date
    let onDeleteEvent: (Event) -> Void
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private let hourHeight: CGFloat = 60  // Base height for one hour
    
    private var isCurrentHour: Bool {
        Calendar.current.isDateInToday(selectedDate) &&
        Calendar.current.component(.hour, from: Date()) == hour
    }
    
    private var hourString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Hour label
            Text(hourString)
                .font(.caption)
                .foregroundColor(isCurrentHour ? themeManager.currentTheme.primaryColor : .secondary)
                .fontWeight(isCurrentHour ? .semibold : .regular)
                .frame(width: 60, alignment: .trailing)
                .padding(.trailing, 8)
                .padding(.top, 4)
            
            // Divider
            Rectangle()
                .fill(isCurrentHour ? themeManager.currentTheme.primaryColor.opacity(0.3) : Color.gray.opacity(0.2))
                .frame(width: 1)
            
            // Events area with proper sizing
            ZStack(alignment: .topLeading) {
                // Background for the hour slot
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: hourHeight)
                
                // Events positioned based on their start time and duration
                ForEach(events) { event in
                    if let eventHour = event.time.map({ Calendar.current.component(.hour, from: $0) }),
                       eventHour == hour {
                        DurationEventCard(
                            event: event,
                            hourHeight: hourHeight,
                            onDelete: { onDeleteEvent(event) }
                        )
                        .offset(y: calculateEventOffset(for: event))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.leading, 8)
        }
        .frame(height: hourHeight)
        .background(isCurrentHour ? themeManager.currentTheme.primaryColor.opacity(0.05) : Color.clear)
    }
    
    // Calculate vertical offset within the hour based on minutes
    private func calculateEventOffset(for event: Event) -> CGFloat {
        guard let time = event.time else { return 0 }
        let minutes = Calendar.current.component(.minute, from: time)
        return (CGFloat(minutes) / 60.0) * hourHeight
    }
}

// MARK: - Duration Event Card

struct DurationEventCard: View {
    let event: Event
    let hourHeight: CGFloat
    let onDelete: () -> Void
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    
    private var displayTime: String {
        if let timeString = event.timeString {
            if let endTime = event.endTime {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                return "\(timeString) - \(formatter.string(from: endTime))"
            }
            return timeString
        }
        return "All day"
    }
    
    // Calculate height based on event duration
    private var eventHeight: CGFloat {
        guard let startTime = event.time, let endTime = event.endTime else {
            return hourHeight * 0.8  // Default height if no end time
        }
        
        let duration = endTime.timeIntervalSince(startTime) / 60  // Duration in minutes
        let hours = duration / 60.0
        return CGFloat(hours) * hourHeight - 8  // Subtract padding
    }
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            HStack(spacing: 8) {
                // Time marker
                Rectangle()
                    .fill(event.isCompleted ? Color.green : themeManager.currentTheme.accentColor)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(displayTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        if event.reminderMinutesBefore != nil {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        
                        if event.recurrenceRule != nil {
                            Image(systemName: "repeat")
                                .font(.caption2)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        
                        Spacer()
                        
                        Button {
                            var updatedEvent = event
                            updatedEvent.isCompleted.toggle()
                            dataManager.updateEvent(updatedEvent)
                        } label: {
                            Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(event.isCompleted ? .green : .gray)
                                .font(.body)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                    
                    if let notes = event.notes, !notes.isEmpty, eventHeight > 60 {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                }
                .padding(.vertical, 6)
                .padding(.trailing, 8)
            }
            .frame(height: eventHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(event.isCompleted ? Color.green.opacity(0.3) : themeManager.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditEventView(event: event)
        }
    }
}

// MARK: - Hourly Event Card (for all-day events)

struct HourlyEventCard: View {
    let event: Event
    let onDelete: () -> Void
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingEditSheet = false
    
    private var displayTime: String {
        if let timeString = event.timeString {
            return timeString
        }
        return "All day"
    }
    
    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            HStack(spacing: 12) {
                // Time marker
                Rectangle()
                    .fill(event.isCompleted ? Color.green : themeManager.currentTheme.accentColor)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(displayTime)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if event.reminderMinutesBefore != nil {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        
                        if event.recurrenceRule != nil {
                            Image(systemName: "repeat")
                                .font(.caption2)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        
                        Spacer()
                        
                        Button {
                            var updatedEvent = event
                            updatedEvent.isCompleted.toggle()
                            dataManager.updateEvent(updatedEvent)
                        } label: {
                            Image(systemName: event.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(event.isCompleted ? .green : .gray)
                                .font(.body)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Text(event.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    if let notes = event.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 8)
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(event.isCompleted ? Color.green.opacity(0.3) : themeManager.currentTheme.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditEventView(event: event)
        }
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedDate: Date
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
                
                Spacer()
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Add Event View

struct AddEventView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    let selectedDate: Date
    
    @State private var title = ""
    @State private var date: Date
    @State private var isAllDay = false
    @State private var hasTime = true
    @State private var time = Date()
    @State private var hasEndTime = false
    @State private var endTime = Date()
    @State private var notes = ""
    @State private var hasAlert = false
    @State private var alertOption: AlertOption = .fifteenMinutes
    @State private var showingPermissionAlert = false
    @State private var isRecurring = false
    @State private var recurrenceRule: Event.RecurrenceRule = .weekly
    @State private var hasRecurrenceEndDate = false
    @State private var recurrenceEndDate = Date()
    
    enum AlertOption: Int, CaseIterable {
        case atTime = 0
        case fiveMinutes = 5
        case tenMinutes = 10
        case fifteenMinutes = 15
        case thirtyMinutes = 30
        case oneHour = 60
        case twoHours = 120
        case oneDay = 1440
        
        var displayName: String {
            switch self {
            case .atTime: return "At time of event"
            case .fiveMinutes: return "5 minutes before"
            case .tenMinutes: return "10 minutes before"
            case .fifteenMinutes: return "15 minutes before"
            case .thirtyMinutes: return "30 minutes before"
            case .oneHour: return "1 hour before"
            case .twoHours: return "2 hours before"
            case .oneDay: return "1 day before"
            }
        }
    }
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        _date = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Event Title", text: $title)
                }
                
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Toggle("All-Day Event", isOn: $isAllDay)
                        .onChange(of: isAllDay) { _, newValue in
                            if newValue {
                                hasTime = false
                                hasEndTime = false
                            } else {
                                hasTime = true
                            }
                        }
                    
                    if !isAllDay {
                        Toggle("Add Time", isOn: $hasTime)
                            .onChange(of: hasTime) { _, newValue in
                                if !newValue {
                                    hasEndTime = false
                                }
                            }
                        
                        if hasTime {
                            DatePicker("Start Time", selection: $time, displayedComponents: .hourAndMinute)
                            
                            Toggle("Add End Time", isOn: $hasEndTime)
                                .onChange(of: hasEndTime) { _, newValue in
                                    if newValue {
                                        // Set end time to 1 hour after start time by default
                                        endTime = Calendar.current.date(byAdding: .hour, value: 1, to: time) ?? time
                                    }
                                }
                            
                            if hasEndTime {
                                DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                            }
                        }
                    }
                }
                
                // Alert section - only show if event has a time
                if hasTime && !isAllDay {
                    Section {
                        Toggle("Set Alert", isOn: $hasAlert)
                        
                        if hasAlert {
                            Picker("Alert me", selection: $alertOption) {
                                ForEach(AlertOption.allCases, id: \.self) { option in
                                    Text(option.displayName)
                                        .tag(option)
                                }
                            }
                            
                            HStack {
                                Image(systemName: "bell.fill")
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                Text("You'll receive a notification")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } header: {
                        Text("Alert")
                    } footer: {
                        if hasAlert {
                            Text("Notifications must be enabled in Settings for alerts to work")
                                .font(.caption)
                        }
                    }
                }
                
                // Recurring event section
                Section {
                    Toggle("Recurring Event", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Repeat", selection: $recurrenceRule) {
                            ForEach(Event.RecurrenceRule.allCases, id: \.self) { rule in
                                Text(rule.displayName)
                                    .tag(rule)
                            }
                        }
                        
                        Toggle("End Date", isOn: $hasRecurrenceEndDate)
                            .onChange(of: hasRecurrenceEndDate) { _, newValue in
                                if newValue {
                                    // Set end date to 3 months from now by default
                                    recurrenceEndDate = Calendar.current.date(byAdding: .month, value: 3, to: date) ?? date
                                }
                            }
                        
                        if hasRecurrenceEndDate {
                            DatePicker("Repeat Until", selection: $recurrenceEndDate, in: date..., displayedComponents: .date)
                        }
                        
                        HStack {
                            Image(systemName: "repeat")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text("Event will repeat \(recurrenceRule.displayName.lowercased())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Recurrence")
                } footer: {
                    if isRecurring && !hasRecurrenceEndDate {
                        Text("This event will repeat indefinitely until you delete it")
                            .font(.caption)
                    }
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Notifications Required", isPresented: $showingPermissionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enable notifications in Settings to receive event alerts.")
            }
        }
    }
    
    private func saveEvent() {
        Task {
            // Check notification permission if alert is enabled
            var notificationIdentifier: String? = nil
            
            if hasAlert {
                let granted = await NotificationManager.shared.requestAuthorization()
                if !granted {
                    showingPermissionAlert = true
                    // Still save the event but without alert
                }
            }
            
            // Generate notification identifier if alert is set
            if hasAlert {
                notificationIdentifier = UUID().uuidString
            }
            
            let newEvent = Event(
                title: title,
                date: date,
                time: (hasTime && !isAllDay) ? time : nil,
                endTime: (hasEndTime && hasTime && !isAllDay) ? endTime : nil,
                isAllDay: isAllDay,
                notes: notes.isEmpty ? nil : notes,
                reminderMinutesBefore: hasAlert ? alertOption.rawValue : nil,
                notificationIdentifier: notificationIdentifier,
                recurrenceRule: isRecurring ? recurrenceRule : nil,
                recurrenceEndDate: (isRecurring && hasRecurrenceEndDate) ? recurrenceEndDate : nil
            )
            
            dataManager.addEvent(newEvent)
            
            // Schedule notification if alert is enabled
            if hasAlert {
                await NotificationManager.shared.scheduleEventReminder(for: newEvent)
            }
            
            await MainActor.run {
                dismiss()
            }
        }
    }
}

// MARK: - Edit Event View

struct EditEventView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title: String
    @State private var date: Date
    @State private var isAllDay: Bool
    @State private var hasTime: Bool
    @State private var time: Date
    @State private var hasEndTime: Bool
    @State private var endTime: Date
    @State private var notes: String
    @State private var hasAlert: Bool
    @State private var alertOption: AddEventView.AlertOption
    @State private var isRecurring: Bool
    @State private var recurrenceRule: Event.RecurrenceRule
    @State private var hasRecurrenceEndDate: Bool
    @State private var recurrenceEndDate: Date
    @State private var showingPermissionAlert = false
    @State private var showingDeleteAlert = false
    
    init(event: Event) {
        self.event = event
        _title = State(initialValue: event.title)
        _date = State(initialValue: event.date)
        _isAllDay = State(initialValue: event.isAllDay)
        _hasTime = State(initialValue: event.time != nil)
        _time = State(initialValue: event.time ?? Date())
        _hasEndTime = State(initialValue: event.endTime != nil)
        _endTime = State(initialValue: event.endTime ?? Date())
        _notes = State(initialValue: event.notes ?? "")
        _hasAlert = State(initialValue: event.reminderMinutesBefore != nil)
        _alertOption = State(initialValue: AddEventView.AlertOption(rawValue: event.reminderMinutesBefore ?? 15) ?? .fifteenMinutes)
        _isRecurring = State(initialValue: event.recurrenceRule != nil)
        _recurrenceRule = State(initialValue: event.recurrenceRule ?? .weekly)
        _hasRecurrenceEndDate = State(initialValue: event.recurrenceEndDate != nil)
        _recurrenceEndDate = State(initialValue: event.recurrenceEndDate ?? Date())
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Event Title", text: $title)
                }
                
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Toggle("All-Day Event", isOn: $isAllDay)
                        .onChange(of: isAllDay) { _, newValue in
                            if newValue {
                                hasTime = false
                                hasEndTime = false
                            } else {
                                hasTime = true
                            }
                        }
                    
                    if !isAllDay {
                        Toggle("Add Time", isOn: $hasTime)
                            .onChange(of: hasTime) { _, newValue in
                                if !newValue {
                                    hasEndTime = false
                                }
                            }
                        
                        if hasTime {
                            DatePicker("Start Time", selection: $time, displayedComponents: .hourAndMinute)
                            
                            Toggle("Add End Time", isOn: $hasEndTime)
                                .onChange(of: hasEndTime) { _, newValue in
                                    if newValue {
                                        endTime = Calendar.current.date(byAdding: .hour, value: 1, to: time) ?? time
                                    }
                                }
                            
                            if hasEndTime {
                                DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                            }
                        }
                    }
                }
                
                // Alert section
                if hasTime && !isAllDay {
                    Section {
                        Toggle("Set Alert", isOn: $hasAlert)
                        
                        if hasAlert {
                            Picker("Alert me", selection: $alertOption) {
                                ForEach(AddEventView.AlertOption.allCases, id: \.self) { option in
                                    Text(option.displayName)
                                        .tag(option)
                                }
                            }
                        }
                    } header: {
                        Text("Alert")
                    }
                }
                
                // Recurring event section
                Section {
                    Toggle("Recurring Event", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Repeat", selection: $recurrenceRule) {
                            ForEach(Event.RecurrenceRule.allCases, id: \.self) { rule in
                                Text(rule.displayName)
                                    .tag(rule)
                            }
                        }
                        
                        Toggle("End Date", isOn: $hasRecurrenceEndDate)
                            .onChange(of: hasRecurrenceEndDate) { _, newValue in
                                if newValue {
                                    recurrenceEndDate = Calendar.current.date(byAdding: .month, value: 3, to: date) ?? date
                                }
                            }
                        
                        if hasRecurrenceEndDate {
                            DatePicker("Repeat Until", selection: $recurrenceEndDate, in: date..., displayedComponents: .date)
                        }
                    }
                } header: {
                    Text("Recurrence")
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Event")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Delete Event", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteEvent()
                }
            } message: {
                Text("Are you sure you want to delete '\(event.title)'? This action cannot be undone.")
            }
        }
    }
    
    private func saveChanges() {
        Task {
            var notificationIdentifier = event.notificationIdentifier
            
            if hasAlert {
                let granted = await NotificationManager.shared.requestAuthorization()
                if !granted {
                    showingPermissionAlert = true
                }
                
                if notificationIdentifier == nil {
                    notificationIdentifier = UUID().uuidString
                }
            }
            
            let updatedEvent = Event(
                id: event.id,
                title: title,
                date: date,
                time: (hasTime && !isAllDay) ? time : nil,
                endTime: (hasEndTime && hasTime && !isAllDay) ? endTime : nil,
                isAllDay: isAllDay,
                notes: notes.isEmpty ? nil : notes,
                isCompleted: event.isCompleted,
                reminderMinutesBefore: hasAlert ? alertOption.rawValue : nil,
                notificationIdentifier: notificationIdentifier,
                recurrenceRule: isRecurring ? recurrenceRule : nil,
                recurrenceEndDate: (isRecurring && hasRecurrenceEndDate) ? recurrenceEndDate : nil
            )
            
            dataManager.updateEvent(updatedEvent)
            
            // Reschedule notification if needed
            if let notifId = event.notificationIdentifier {
                await NotificationManager.shared.cancelEventReminder(identifier: notifId)
            }
            
            if hasAlert {
                await NotificationManager.shared.scheduleEventReminder(for: updatedEvent)
            }
            
            await MainActor.run {
                dismiss()
            }
        }
    }
    
    private func deleteEvent() {
        if let notificationId = event.notificationIdentifier {
            NotificationManager.shared.cancelEventReminder(identifier: notificationId)
        }
        dataManager.deleteEvent(event)
        dismiss()
    }
}

