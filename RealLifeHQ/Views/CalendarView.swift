import SwiftUI

// MARK: - Calendar View
// Manage and view all your events and appointments in an hourly daily view

struct CalendarView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedDate = Date()
    @State private var showingAddEvent = false
    @State private var showingDatePicker = false
    
    private let hours = Array(0...23)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Date selector header
                dateHeaderView
                
                Divider()
                
                // Hourly schedule view
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
            
            // Events area
            VStack(alignment: .leading, spacing: 8) {
                if events.isEmpty {
                    // Empty hour
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 60)
                } else {
                    // Events for this hour
                    ForEach(events) { event in
                        HourlyEventCard(event: event, onDelete: {
                            onDeleteEvent(event)
                        })
                    }
                    .padding(.vertical, 4)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
        }
        .background(isCurrentHour ? themeManager.currentTheme.primaryColor.opacity(0.05) : Color.clear)
    }
}

// MARK: - Hourly Event Card

struct HourlyEventCard: View {
    let event: Event
    let onDelete: () -> Void
    
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var displayTime: String {
        if let timeString = event.timeString {
            return timeString
        }
        return "All day"
    }
    
    var body: some View {
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
                }
                
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
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
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
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
    @State private var hasReminder = false
    @State private var reminderOption: ReminderOption = .fifteenMinutes
    @State private var showingPermissionAlert = false
    
    enum ReminderOption: Int, CaseIterable {
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
                
                // Reminder section - only show if event has a time
                if hasTime && !isAllDay {
                    Section {
                        Toggle("Set Reminder", isOn: $hasReminder)
                        
                        if hasReminder {
                            Picker("Remind me", selection: $reminderOption) {
                                ForEach(ReminderOption.allCases, id: \.self) { option in
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
                        Text("Reminder")
                    } footer: {
                        if hasReminder {
                            Text("Notifications must be enabled in Settings for reminders to work")
                                .font(.caption)
                        }
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
                Text("Please enable notifications in Settings to receive event reminders.")
            }
        }
    }
    
    private func saveEvent() {
        Task {
            // Check notification permission if reminder is enabled
            var notificationIdentifier: String? = nil
            
            if hasReminder {
                let granted = await NotificationManager.shared.requestAuthorization()
                if !granted {
                    showingPermissionAlert = true
                    // Still save the event but without reminder
                }
            }
            
            // Generate notification identifier if reminder is set
            if hasReminder {
                notificationIdentifier = UUID().uuidString
            }
            
            let newEvent = Event(
                title: title,
                date: date,
                time: (hasTime && !isAllDay) ? time : nil,
                endTime: (hasEndTime && hasTime && !isAllDay) ? endTime : nil,
                isAllDay: isAllDay,
                notes: notes.isEmpty ? nil : notes,
                reminderMinutesBefore: hasReminder ? reminderOption.rawValue : nil,
                notificationIdentifier: notificationIdentifier
            )
            
            dataManager.addEvent(newEvent)
            
            // Schedule notification if reminder is enabled
            if hasReminder {
                await NotificationManager.shared.scheduleEventReminder(for: newEvent)
            }
            
            await MainActor.run {
                dismiss()
            }
        }
    }
}
