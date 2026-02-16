import SwiftUI

import SwiftUI

// MARK: - Reminder Wizard Main View

struct ReminderWizardView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @State private var currentStep: WizardStep = .welcome
    @State private var selectedSituations: Set<LifeSituation> = []
    @State private var suggestedReminders: [ReminderTemplate] = []
    @State private var showingAddEvent = false
    @State private var selectedTemplate: ReminderTemplate?
    
    enum WizardStep {
        case welcome
        case questions
        case suggestions
        case complete
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.currentTheme.backgroundColor.ignoresSafeArea()
                
                switch currentStep {
                case .welcome:
                    welcomeView
                case .questions:
                    questionsView
                case .suggestions:
                    suggestionsView
                case .complete:
                    completeView
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep != .welcome {
                        Button("Back") {
                            goBack()
                        }
                    } else {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentStep == .complete {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                if let template = selectedTemplate {
                    ReminderWizardAddEventView(template: template)
                }
            }
        }
    }
    
    private var navigationTitle: String {
        switch currentStep {
        case .welcome: return "Reminder Wizard"
        case .questions: return "About You"
        case .suggestions: return "Suggested Reminders"
        case .complete: return "All Set!"
        }
    }
    
    // MARK: - Welcome View
    
    private var welcomeView: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 40)
                
                // Icon
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.primaryColor,
                                themeManager.currentTheme.accentColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Title
                Text("Life Reminder Setup")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Description
                Text("Never forget important life tasks again! Answer a few questions and we'll suggest personalized reminders for things like:")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Example badges
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        exampleBadge("Oil changes", icon: "car.fill")
                        exampleBadge("Vet visits", icon: "pawprint.fill")
                    }
                    HStack(spacing: 12) {
                        exampleBadge("Dental cleanings", icon: "cross.case.fill")
                        exampleBadge("Tax deadlines", icon: "doc.text.fill")
                    }
                }
                .padding(.vertical)
                
                Spacer()
                
                // Get Started Button
                Button {
                    withAnimation {
                        currentStep = .questions
                    }
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 40)
            }
        }
    }
    
    private func exampleBadge(_ text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(themeManager.currentTheme.primaryColor.opacity(0.1))
        .foregroundColor(themeManager.currentTheme.primaryColor)
        .cornerRadius(16)
    }
    
    // MARK: - Questions View
    
    private var questionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell us about your life")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select all that apply to you. We'll use this to suggest relevant reminders.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Questions
                VStack(spacing: 12) {
                    ForEach(LifeSituation.allCases) { situation in
                        QuestionCard(
                            situation: situation,
                            isSelected: selectedSituations.contains(situation)
                        ) {
                            toggleSituation(situation)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Continue Button
                Button {
                    generateSuggestions()
                    withAnimation {
                        currentStep = .suggestions
                    }
                } label: {
                    Text("Show My Reminders")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
    }
    
    // MARK: - Suggestions View
    
    private var suggestionsView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Personalized Reminders")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Tap 'Set Up' to add any reminder to your calendar. You can customize the date and details.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Reminders count
                HStack {
                    Image(systemName: "calendar.badge.checkmark")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("\(suggestedReminders.count) reminders suggested for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Grouped reminders
                ForEach(groupedReminders, id: \.key) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        // Group header
                        Text(group.key)
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Reminders in group
                        ForEach(group.value) { reminder in
                            ReminderSuggestionCard(reminder: reminder) {
                                selectedTemplate = reminder
                                showingAddEvent = true
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Done button
                Button {
                    withAnimation {
                        currentStep = .complete
                    }
                } label: {
                    Text("I'm All Set")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding()
            }
        }
    }
    
    private var groupedReminders: [(key: String, value: [ReminderTemplate])] {
        let grouped = Dictionary(grouping: suggestedReminders) { reminder -> String in
            if reminder.category == nil {
                return "Essential (Everyone)"
            } else {
                return reminder.category?.rawValue ?? "Other"
            }
        }
        
        // Sort so universal comes first
        return grouped.sorted { lhs, rhs in
            if lhs.key == "Essential (Everyone)" { return true }
            if rhs.key == "Essential (Everyone)" { return false }
            return lhs.key < rhs.key
        }
    }
    
    // MARK: - Complete View
    
    private var completeView: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 60)
                
                // Success icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                // Title
                Text("You're All Set!")
                    .font(.title)
                    .fontWeight(.bold)
                
                // Message
                Text("Your reminders are ready. You can always add more reminders from the Calendar view.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 40)
                
                // Stats
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        statCard(
                            value: "\(suggestedReminders.count)",
                            label: "Reminders\nSuggested",
                            icon: "list.bullet"
                        )
                        
                        statCard(
                            value: "0",
                            label: "Events\nCreated",
                            icon: "calendar.badge.plus"
                        )
                    }
                }
                .padding(.vertical)
                
                // Tip
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Pro Tip")
                            .font(.headline)
                    }
                    
                    Text("You can run this wizard again anytime from the Calendar settings to add more reminders as your life changes.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
    
    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
    
    // MARK: - Helper Functions
    
    private func toggleSituation(_ situation: LifeSituation) {
        if selectedSituations.contains(situation) {
            selectedSituations.remove(situation)
        } else {
            selectedSituations.insert(situation)
        }
    }
    
    private func generateSuggestions() {
        suggestedReminders = ReminderTemplatesDatabase.getTemplates(for: selectedSituations)
    }
    
    private func goBack() {
        withAnimation {
            switch currentStep {
            case .questions:
                currentStep = .welcome
            case .suggestions:
                currentStep = .questions
            case .complete:
                currentStep = .suggestions
            case .welcome:
                break
            }
        }
    }
}

// MARK: - Question Card

struct QuestionCard: View {
    let situation: LifeSituation
    let isSelected: Bool
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: situation.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : themeManager.currentTheme.primaryColor)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.primaryColor.opacity(0.1))
                    )
                
                // Question text
                Text(situation.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Checkmark
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? themeManager.currentTheme.accentColor : .gray)
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? themeManager.currentTheme.primaryColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reminder Suggestion Card

struct ReminderSuggestionCard: View {
    let reminder: ReminderTemplate
    let action: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Image(systemName: reminder.icon)
                    .font(.title2)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(reminder.title)
                        .font(.headline)
                    
                    // Description
                    Text(reminder.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Frequency badge
                    HStack(spacing: 4) {
                        Image(systemName: "repeat")
                            .font(.caption2)
                        Text(reminder.suggestedFrequency.rawValue)
                            .font(.caption)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.currentTheme.accentColor.opacity(0.1))
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .cornerRadius(8)
                    .padding(.top, 4)
                }
                
                Spacer()
            }
            
            // Set up button
            Button(action: action) {
                Text("Set Up")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(themeManager.currentTheme.primaryColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
}

// MARK: - Reminder Wizard Add Event View

struct ReminderWizardAddEventView: View {
    let template: ReminderTemplate
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var title: String
    @State private var date = Date()
    @State private var time = Date()
    @State private var hasAlert = true
    @State private var alertOption: AddEventView.AlertOption = .fifteenMinutes
    @State private var isRecurring = true
    @State private var recurrenceRule: Event.RecurrenceRule
    @State private var notes = ""
    
    init(template: ReminderTemplate) {
        self.template = template
        _title = State(initialValue: template.title)
        _recurrenceRule = State(initialValue: template.suggestedFrequency.recurrenceRule)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Toggle("Recurring Event", isOn: $isRecurring)
                    
                    if isRecurring {
                        Picker("Repeat", selection: $recurrenceRule) {
                            ForEach(Event.RecurrenceRule.allCases, id: \.self) { rule in
                                Text(rule.displayName).tag(rule)
                            }
                        }
                        
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                            Text("Suggested: \(template.suggestedFrequency.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Recurrence")
                }
                
                Section {
                    Toggle("Set Alert", isOn: $hasAlert)
                    
                    if hasAlert {
                        Picker("Alert me", selection: $alertOption) {
                            ForEach(AddEventView.AlertOption.allCases, id: \.self) { option in
                                Text(option.displayName).tag(option)
                            }
                        }
                    }
                } header: {
                    Text("Alert")
                }
                
                Section("Notes (Optional)") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text(template.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Set Up Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        saveEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
    
    private func saveEvent() {
        let newEvent = Event(
            title: title,
            date: date,
            time: time,
            endTime: nil,
            isAllDay: false,
            notes: notes.isEmpty ? nil : notes,
            reminderMinutesBefore: hasAlert ? alertOption.rawValue : nil,
            notificationIdentifier: hasAlert ? UUID().uuidString : nil,
            recurrenceRule: isRecurring ? recurrenceRule : nil,
            recurrenceEndDate: nil
        )
        
        dataManager.addEvent(newEvent)
        
        if hasAlert {
            Task {
                await NotificationManager.shared.scheduleEventReminder(for: newEvent)
            }
        }
        
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    ReminderWizardView()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
