import SwiftUI

// MARK: - Habits View
// Track your daily habits and build streaks

struct HabitsView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if dataManager.habits.isEmpty {
                    emptyStateView
                } else {
                    habitsList
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
                HabitDetailRow(habit: habit)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            dataManager.deleteHabit(habit)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
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
        }
    }
    
    private func saveHabit() {
        // Use theme primary color as the habit color
        let habitColor = themeManager.currentTheme.primaryColor
        let colorName = colorToString(habitColor)
        
        let newHabit = Habit(
            name: name,
            icon: selectedIcon,
            color: colorName,
            frequency: frequency,
            selectedDays: frequency == .daily ? Set([1, 2, 3, 4, 5, 6, 7]) : selectedDays
        )
        dataManager.addHabit(newHabit)
        dismiss()
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

