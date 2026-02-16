import SwiftUI

// MARK: - Habits View
// Track your daily habits and build streaks

struct HabitsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if dataManager.habits.isEmpty {
                    emptyStateView
                } else {
                    VStack(spacing: 0) {
                        // Instructions banner
                        instructionsBanner
                        
                        if horizontalSizeClass == .regular {
                            // iPad: Grid layout
                            iPadGridLayout
                        } else {
                            // iPhone: List layout
                            habitsList
                        }
                    }
                }
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Habits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddHabit = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // Instructions banner
    private var instructionsBanner: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Text("Quick Guide")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                    Text("Tap the circle to mark habits complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "hand.tap")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 16)
                    Text("Long press on a habit to edit or delete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.currentTheme.cardColor)
    }
    
    // iPad Grid Layout
    private var iPadGridLayout: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)
            ], spacing: 20) {
                ForEach(dataManager.habits) { habit in
                    HabitCardView(habit: habit)
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.5))
            
            Text("No Habits Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start building better habits today")
                .foregroundColor(.secondary)
            
            Button("Add Your First Habit") {
                showingAddHabit = true
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.currentTheme.primaryColor)
        }
    }
    
    private var habitsList: some View {
        List {
            ForEach(dataManager.habits) { habit in
                HabitDetailRowWithActions(habit: habit)
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Habit Card View (iPad Grid)

struct HabitCardView: View {
    let habit: Habit
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showDeleteAlert = false
    
    private var habitColor: Color {
        switch habit.color.lowercased() {
        case "teal": return Color.teal
        case "purple": return Color.purple
        case "blue": return Color.blue
        case "green": return Color.green
        case "pink": return Color.pink
        case "orange": return Color.orange
        case "red": return Color.red
        case "yellow": return Color.yellow
        case "indigo": return Color.indigo
        case "cyan": return Color.cyan
        case "mint": return Color.mint
        case "gray": return Color.gray
        default: return themeManager.currentTheme.primaryColor
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Icon and completion button
            HStack {
                Circle()
                    .fill(habitColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: habit.icon)
                            .foregroundColor(habitColor)
                            .font(.title2)
                    )
                
                Spacer()
                
                Button {
                    dataManager.toggleHabit(habit)
                } label: {
                    Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(habit.isCompletedToday() ? .green : .gray)
                        .font(.system(size: 36))
                }
            }
            
            // Habit name
            Text(habit.name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Stats
            HStack(spacing: 16) {
                Label("\(habit.currentStreak())", systemImage: "flame.fill")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
                Label(habit.frequency.rawValue, systemImage: "repeat")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Delete button
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .alert("Delete Habit", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteHabit(habit)
            }
        } message: {
            Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
        }
    }
}

// MARK: - Habit Detail Row with Actions

struct HabitDetailRowWithActions: View {
    let habit: Habit
    @EnvironmentObject var dataManager: DataManager
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        HabitDetailRow(habit: habit)
            .contextMenu {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Edit Habit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Label("Delete Habit", systemImage: "trash")
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                NavigationView {
                    EditHabitView(habit: habit)
                }
            }
            .alert("Delete Habit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    dataManager.deleteHabit(habit)
                }
            } message: {
                Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
            }
    }
}

// MARK: - Habit Detail Row

struct HabitDetailRow: View {
    let habit: Habit
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    private var habitColor: Color {
        // Use theme color or fallback to habit's stored color
        switch habit.color.lowercased() {
        case "teal": return Color.teal
        case "purple": return Color.purple
        case "blue": return Color.blue
        case "green": return Color.green
        case "pink": return Color.pink
        case "orange": return Color.orange
        case "red": return Color.red
        case "yellow": return Color.yellow
        case "indigo": return Color.indigo
        case "cyan": return Color.cyan
        case "mint": return Color.mint
        case "gray": return Color.gray
        default: return themeManager.currentTheme.primaryColor
        }
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            Circle()
                .fill(habitColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: habit.icon)
                        .foregroundColor(habitColor)
                        .font(.title3)
                )
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Label("\(habit.currentStreak())", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Label(habit.frequency.rawValue, systemImage: "repeat")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Completion button
            Button {
                dataManager.toggleHabit(habit)
            } label: {
                Image(systemName: habit.isCompletedToday() ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(habit.isCompletedToday() ? .green : .gray)
                    .font(.system(size: 32))
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Add Habit View

struct AddHabitView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var name = ""
    @State private var selectedIcon = "figure.walk"
    @State private var frequency: Habit.Frequency = .daily
    @State private var selectedDays: Set<Int> = Set([1, 2, 3, 4, 5, 6, 7])
    @State private var showingIconPicker = false
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var showingPermissionAlert = false
    @State private var addToCalendar = false
    @State private var calendarDuration = 30
    @State private var showingCalendarPermissionAlert = false
    
    // Available icons organized by category
    let iconCategories: [(String, [String])] = [
        ("Fitness", ["figure.walk", "figure.run", "figure.yoga", "dumbbell.fill", "bicycle", "figure.swimming", "figure.climbing", "sportscourt.fill"]),
        ("Health", ["heart.fill", "bed.double.fill", "pills.fill", "cross.case.fill", "lungs.fill", "brain.head.profile", "drop.fill", "leaf.fill"]),
        ("Learning", ["book.fill", "graduationcap.fill", "pencil", "newspaper.fill", "lightbulb.fill", "character.book.closed.fill", "trophy.fill", "target"]),
        ("Food", ["fork.knife", "cup.and.saucer.fill", "wineglass", "carrot.fill", "fish.fill", "cup.and.heat.waves.fill", "birthday.cake.fill", "takeoutbag.and.cup.and.straw.fill"]),
        ("Mindfulness", ["brain.head.profile", "moon.stars.fill", "sun.max.fill", "sparkles", "hands.sparkles.fill", "music.note", "headphones", "flame.fill"]),
        ("Productivity", ["checkmark.circle.fill", "calendar", "clock.fill", "bell.fill", "hourglass", "envelope.fill", "phone.fill", "chart.line.uptrend.xyaxis"]),
        ("Nature", ["tree.fill", "cloud.sun.fill", "wind", "snowflake", "thermometer.sun.fill", "moon.fill", "star.fill", "globe.americas.fill"]),
        ("Other", ["house.fill", "car.fill", "briefcase.fill", "pawprint.fill", "gamecontroller.fill", "paintbrush.fill", "camera.fill", "gift.fill"])
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Habit Details") {
                    TextField("Habit Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    // Icon selector button
                    Button {
                        showingIconPicker = true
                    } label: {
                        HStack {
                            Text("Icon")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: selectedIcon)
                                .font(.title2)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .frame(width: 40, height: 40)
                                .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                                .cornerRadius(8)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Picker("Frequency", selection: $frequency) {
                        ForEach(Habit.Frequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue).tag(freq)
                        }
                    }
                    .onChange(of: frequency) { oldValue, newValue in
                        // If switching to daily, select all days
                        if newValue == .daily {
                            selectedDays = Set([1, 2, 3, 4, 5, 6, 7])
                        }
                    }
                } header: {
                    Text("Frequency")
                } footer: {
                    if frequency == .specificDays {
                        Text("Choose which days of the week you want to do this habit")
                    } else if frequency == .daily {
                        Text("This habit will be tracked every day")
                    }
                }
                
                // Day selector - only show for specific days
                if frequency == .specificDays {
                    Section("Days of the Week") {
                        DayOfWeekPicker(selectedDays: $selectedDays)
                            .padding(.vertical, 8)
                    }
                }
                
                // Reminder section
                Section {
                    Toggle("Daily Reminder", isOn: $reminderEnabled)
                    
                    if reminderEnabled {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    if reminderEnabled {
                        Text("You'll receive a reminder at this time on the days you've selected for this habit")
                    } else {
                        Text("Enable to get reminded to complete this habit")
                    }
                }
                
                // Calendar Integration section
                Section {
                    Toggle("Add to Calendar", isOn: $addToCalendar)
                    
                    if addToCalendar {
                        if reminderEnabled {
                            Picker("Duration", selection: $calendarDuration) {
                                Text("15 minutes").tag(15)
                                Text("30 minutes").tag(30)
                                Text("45 minutes").tag(45)
                                Text("1 hour").tag(60)
                                Text("1.5 hours").tag(90)
                                Text("2 hours").tag(120)
                            }
                        } else {
                            Text("Enable reminder to set time for calendar events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Calendar")
                } footer: {
                    if addToCalendar && reminderEnabled {
                        Text("Recurring events will be added to your device calendar at the reminder time for the selected duration")
                    } else if addToCalendar && !reminderEnabled {
                        Text("Enable a reminder to set the time for calendar events")
                    } else {
                        Text("Add this habit as recurring events to your calendar")
                    }
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveHabit()
                    }
                    .disabled(name.isEmpty || (frequency == .specificDays && selectedDays.isEmpty))
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon)
            }
            .alert("Notifications Permission Required", isPresented: $showingPermissionAlert) {
                Button("Cancel", role: .cancel) {
                    reminderEnabled = false
                }
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable notifications in Settings to receive habit reminders")
            }
            .alert("Calendar Permission Required", isPresented: $showingCalendarPermissionAlert) {
                Button("Cancel", role: .cancel) {
                    addToCalendar = false
                }
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable calendar access in Settings to add habits to your calendar")
            }
        }
    }
    
    private func saveHabit() {
        // Check notification permission if reminder is enabled
        if reminderEnabled {
            Task {
                let granted = await NotificationManager.shared.requestAuthorization()
                if !granted {
                    await MainActor.run {
                        showingPermissionAlert = true
                    }
                    return
                }
                
                await MainActor.run {
                    createAndSaveHabit()
                }
            }
        } else {
            createAndSaveHabit()
        }
    }
    
    private func createAndSaveHabit() {
        // Use theme primary color as the habit color
        let habitColor = themeManager.currentTheme.primaryColor
        let colorName = colorToString(habitColor)
        
        var newHabit = Habit(
            name: name,
            icon: selectedIcon,
            color: colorName,
            frequency: frequency,
            selectedDays: frequency == .daily ? Set([1, 2, 3, 4, 5, 6, 7]) : selectedDays,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderEnabled ? reminderTime : nil
        )
        
        newHabit.addToCalendar = addToCalendar
        newHabit.calendarDuration = calendarDuration
        
        // Handle calendar integration
        if addToCalendar && reminderEnabled {
            Task {
                let calendarGranted = await HabitCalendarManager.shared.requestCalendarAccess()
                if !calendarGranted {
                    await MainActor.run {
                        showingCalendarPermissionAlert = true
                        addToCalendar = false
                    }
                    return
                }
                
                // Add to calendar
                let eventIds = await HabitCalendarManager.shared.addHabitToCalendar(habit: newHabit)
                await MainActor.run {
                    newHabit.calendarEventIdentifiers = eventIds
                    dataManager.addHabit(newHabit)
                    dismiss()
                }
            }
        } else {
            dataManager.addHabit(newHabit)
            dismiss()
        }
    }
    
    private func colorToString(_ color: Color) -> String {
        // Extract color based on theme
        switch themeManager.currentTheme {
        case .tealAmber: return "teal"
        case .purplePink: return "purple"
        case .blueGreen: return "blue"
        case .emeraldViolet: return "green"
        }
    }
}

// MARK: - Edit Habit View

struct EditHabitView: View {
    let habit: Habit
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var name = ""
    @State private var selectedIcon = "figure.walk"
    @State private var frequency: Habit.Frequency = .daily
    @State private var selectedDays: Set<Int> = Set([1, 2, 3, 4, 5, 6, 7])
    @State private var showingIconPicker = false
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var showingPermissionAlert = false
    @State private var showingDeleteAlert = false
    @State private var addToCalendar = false
    @State private var calendarDuration = 30
    @State private var showingCalendarPermissionAlert = false
    
    let iconCategories: [(String, [String])] = [
        ("Fitness", ["figure.walk", "figure.run", "figure.yoga", "dumbbell.fill", "bicycle", "figure.swimming", "figure.climbing", "sportscourt.fill"]),
        ("Health", ["heart.fill", "bed.double.fill", "pills.fill", "cross.case.fill", "lungs.fill", "brain.head.profile", "drop.fill", "leaf.fill"]),
        ("Learning", ["book.fill", "graduationcap.fill", "pencil", "newspaper.fill", "lightbulb.fill", "character.book.closed.fill", "trophy.fill", "target"]),
        ("Food", ["fork.knife", "cup.and.saucer.fill", "wineglass", "carrot.fill", "fish.fill", "cup.and.heat.waves.fill", "birthday.cake.fill", "takeoutbag.and.cup.and.straw.fill"]),
        ("Mindfulness", ["brain.head.profile", "moon.stars.fill", "sun.max.fill", "sparkles", "hands.sparkles.fill", "music.note", "headphones", "flame.fill"]),
        ("Productivity", ["checkmark.circle.fill", "calendar", "clock.fill", "bell.fill", "hourglass", "envelope.fill", "phone.fill", "chart.line.uptrend.xyaxis"]),
        ("Nature", ["tree.fill", "cloud.sun.fill", "wind", "snowflake", "thermometer.sun.fill", "moon.fill", "star.fill", "globe.americas.fill"]),
        ("Other", ["house.fill", "car.fill", "briefcase.fill", "pawprint.fill", "gamecontroller.fill", "paintbrush.fill", "camera.fill", "gift.fill"])
    ]
    
    var body: some View {
        Form {
            Section("Habit Details") {
                TextField("Habit Name", text: $name)
                    .textInputAutocapitalization(.words)
                
                Button {
                    showingIconPicker = true
                } label: {
                    HStack {
                        Text("Icon")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: selectedIcon)
                            .font(.title2)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .frame(width: 40, height: 40)
                            .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                            .cornerRadius(8)
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section {
                Picker("Frequency", selection: $frequency) {
                    ForEach(Habit.Frequency.allCases, id: \.self) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                .onChange(of: frequency) { oldValue, newValue in
                    if newValue == .daily {
                        selectedDays = Set([1, 2, 3, 4, 5, 6, 7])
                    }
                }
            } header: {
                Text("Frequency")
            } footer: {
                if frequency == .specificDays {
                    Text("Choose which days of the week you want to do this habit")
                } else if frequency == .daily {
                    Text("This habit will be tracked every day")
                }
            }
            
            if frequency == .specificDays {
                Section("Days of the Week") {
                    DayOfWeekPicker(selectedDays: $selectedDays)
                        .padding(.vertical, 8)
                }
            }
            
            Section {
                Toggle("Daily Reminder", isOn: $reminderEnabled)
                
                if reminderEnabled {
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                }
            } header: {
                Text("Notifications")
            } footer: {
                if reminderEnabled {
                    Text("You'll receive a reminder at this time on the days you've selected for this habit")
                } else {
                    Text("Enable to get reminded to complete this habit")
                }
            }
            
            // Calendar Integration section
            Section {
                Toggle("Add to Calendar", isOn: $addToCalendar)
                    .onChange(of: addToCalendar) { oldValue, newValue in
                        if !newValue && !habit.calendarEventIdentifiers.isEmpty {
                            // User is disabling calendar - will remove events on save
                        }
                    }
                
                if addToCalendar {
                    if reminderEnabled {
                        Picker("Duration", selection: $calendarDuration) {
                            Text("15 minutes").tag(15)
                            Text("30 minutes").tag(30)
                            Text("45 minutes").tag(45)
                            Text("1 hour").tag(60)
                            Text("1.5 hours").tag(90)
                            Text("2 hours").tag(120)
                        }
                    } else {
                        Text("Enable reminder to set time for calendar events")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                Text("Calendar")
            } footer: {
                if addToCalendar && reminderEnabled {
                    Text("Recurring events will be added to your device calendar at the reminder time for the selected duration")
                } else if addToCalendar && !reminderEnabled {
                    Text("Enable a reminder to set the time for calendar events")
                } else if !addToCalendar && !habit.calendarEventIdentifiers.isEmpty {
                    Text("Calendar events will be removed when you save")
                } else {
                    Text("Add this habit as recurring events to your calendar")
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Label("Delete Habit", systemImage: "trash")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Edit Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveHabit()
                }
                .disabled(name.isEmpty || (frequency == .specificDays && selectedDays.isEmpty))
            }
        }
        .sheet(isPresented: $showingIconPicker) {
            IconPickerView(selectedIcon: $selectedIcon)
        }
        .alert("Notifications Permission Required", isPresented: $showingPermissionAlert) {
            Button("Cancel", role: .cancel) {
                reminderEnabled = false
            }
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable notifications in Settings to receive habit reminders")
        }
        .alert("Calendar Permission Required", isPresented: $showingCalendarPermissionAlert) {
            Button("Cancel", role: .cancel) {
                addToCalendar = false
            }
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please enable calendar access in Settings to add habits to your calendar")
        }
        .alert("Delete Habit", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Remove calendar events if they exist
                if !habit.calendarEventIdentifiers.isEmpty {
                    Task {
                        await HabitCalendarManager.shared.removeHabitFromCalendar(eventIdentifiers: habit.calendarEventIdentifiers)
                    }
                }
                dataManager.deleteHabit(habit)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete '\(habit.name)'? This action cannot be undone.")
        }
        .onAppear {
            // Pre-populate with existing habit data
            name = habit.name
            selectedIcon = habit.icon
            frequency = habit.frequency
            selectedDays = habit.selectedDays
            reminderEnabled = habit.reminderEnabled
            reminderTime = habit.reminderTime ?? Date()
            addToCalendar = habit.addToCalendar
            calendarDuration = habit.calendarDuration
        }
    }
    
    private func saveHabit() {
        if reminderEnabled {
            Task {
                let granted = await NotificationManager.shared.requestAuthorization()
                if !granted {
                    await MainActor.run {
                        showingPermissionAlert = true
                    }
                    return
                }
                
                await MainActor.run {
                    updateHabit()
                }
            }
        } else {
            updateHabit()
        }
    }
    
    private func updateHabit() {
        var updatedHabit = habit
        updatedHabit.name = name
        updatedHabit.icon = selectedIcon
        updatedHabit.frequency = frequency
        updatedHabit.selectedDays = frequency == .daily ? Set([1, 2, 3, 4, 5, 6, 7]) : selectedDays
        updatedHabit.reminderEnabled = reminderEnabled
        updatedHabit.reminderTime = reminderEnabled ? reminderTime : nil
        updatedHabit.addToCalendar = addToCalendar
        updatedHabit.calendarDuration = calendarDuration
        
        // Handle calendar changes
        let oldEventIds = habit.calendarEventIdentifiers
        
        // Check if calendar settings changed
        let calendarStatusChanged = addToCalendar != habit.addToCalendar
        let timeChanged = reminderTime != habit.reminderTime
        let frequencyChanged = frequency != habit.frequency
        let daysChanged = selectedDays != habit.selectedDays
        let durationChanged = calendarDuration != habit.calendarDuration
        
        let needsCalendarUpdate = calendarStatusChanged || 
                                  (addToCalendar && (timeChanged || frequencyChanged || daysChanged || durationChanged))
        
        if needsCalendarUpdate {
            if addToCalendar && reminderEnabled {
                Task {
                    let calendarGranted = await HabitCalendarManager.shared.requestCalendarAccess()
                    if !calendarGranted {
                        await MainActor.run {
                            showingCalendarPermissionAlert = true
                            addToCalendar = false
                        }
                        return
                    }
                    
                    // Update calendar events
                    let newEventIds = await HabitCalendarManager.shared.updateHabitInCalendar(
                        habit: updatedHabit,
                        oldEventIds: oldEventIds
                    )
                    
                    await MainActor.run {
                        updatedHabit.calendarEventIdentifiers = newEventIds
                        dataManager.updateHabit(updatedHabit)
                        dismiss()
                    }
                }
            } else {
                // Remove calendar events
                Task {
                    _ = await HabitCalendarManager.shared.removeHabitFromCalendar(eventIdentifiers: oldEventIds)
                    await MainActor.run {
                        updatedHabit.calendarEventIdentifiers = []
                        dataManager.updateHabit(updatedHabit)
                        dismiss()
                    }
                }
            }
        } else {
            dataManager.updateHabit(updatedHabit)
            dismiss()
        }
    }
}

// MARK: - Day of Week Picker

struct DayOfWeekPicker: View {
    @Binding var selectedDays: Set<Int>
    @EnvironmentObject var themeManager: ThemeManager
    
    let days: [(Int, String)] = [
        (1, "S"),   // Sunday
        (2, "M"),   // Monday
        (3, "T"),   // Tuesday
        (4, "W"),   // Wednesday
        (5, "T"),   // Thursday
        (6, "F"),   // Friday
        (7, "S")    // Saturday
    ]
    
    let dayNames: [Int: String] = [
        1: "Sunday",
        2: "Monday",
        3: "Tuesday",
        4: "Wednesday",
        5: "Thursday",
        6: "Friday",
        7: "Saturday"
    ]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.0) { day in
                dayButton(for: day.0, label: day.1)
            }
        }
    }
    
    private func dayButton(for dayNumber: Int, label: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if selectedDays.contains(dayNumber) {
                    selectedDays.remove(dayNumber)
                } else {
                    selectedDays.insert(dayNumber)
                }
            }
        } label: {
            Text(label)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(selectedDays.contains(dayNumber) ? .white : themeManager.currentTheme.primaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selectedDays.contains(dayNumber) ?
                              themeManager.currentTheme.primaryColor :
                              themeManager.currentTheme.primaryColor.opacity(0.15))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Icon Picker View

struct IconPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedIcon: String
    @EnvironmentObject var themeManager: ThemeManager
    
    // Available icons organized by category
    let iconCategories: [(String, [String])] = [
        ("Fitness", ["figure.walk", "figure.run", "figure.yoga", "dumbbell.fill", "bicycle", "figure.swimming", "figure.climbing", "sportscourt.fill"]),
        ("Health", ["heart.fill", "bed.double.fill", "pills.fill", "cross.case.fill", "lungs.fill", "brain.head.profile", "drop.fill", "leaf.fill"]),
        ("Learning", ["book.fill", "graduationcap.fill", "pencil", "newspaper.fill", "lightbulb.fill", "character.book.closed.fill", "trophy.fill", "target"]),
        ("Food", ["fork.knife", "cup.and.saucer.fill", "wineglass", "carrot.fill", "fish.fill", "cup.and.heat.waves.fill", "birthday.cake.fill", "takeoutbag.and.cup.and.straw.fill"]),
        ("Mindfulness", ["brain.head.profile", "moon.stars.fill", "sun.max.fill", "sparkles", "hands.sparkles.fill", "music.note", "headphones", "flame.fill"]),
        ("Productivity", ["checkmark.circle.fill", "calendar", "clock.fill", "bell.fill", "hourglass", "envelope.fill", "phone.fill", "chart.line.uptrend.xyaxis"]),
        ("Nature", ["tree.fill", "cloud.sun.fill", "wind", "snowflake", "thermometer.sun.fill", "moon.fill", "star.fill", "globe.americas.fill"]),
        ("Other", ["house.fill", "car.fill", "briefcase.fill", "pawprint.fill", "gamecontroller.fill", "paintbrush.fill", "camera.fill", "gift.fill"])
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(iconCategories, id: \.0) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.0)
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .padding(.horizontal)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                                ForEach(category.1, id: \.self) { icon in
                                    iconButton(icon)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
    }
    
    private func iconButton(_ icon: String) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedIcon = icon
            }
        } label: {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(selectedIcon == icon ? .white : themeManager.currentTheme.primaryColor)
                    .frame(width: 70, height: 70)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedIcon == icon ?
                                  themeManager.currentTheme.primaryColor :
                                  themeManager.currentTheme.primaryColor.opacity(0.15))
                    )
                
                if selectedIcon == icon {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

