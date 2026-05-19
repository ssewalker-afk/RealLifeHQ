import SwiftUI

// MARK: - Step 2: Cleaning Preferences

struct Step2Preferences: View {
    @Binding var profile: CleaningProfile
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("How do you want to clean?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Set your schedule and time commitment")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Daily Time Commitment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Time Commitment")
                        .font(.headline)
                    
                    Text("Recommended: 30 minutes for sustainable cleaning")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach([15, 30, 45, 60], id: \.self) { minutes in
                            Button {
                                profile.dailyTimeCommitment = minutes
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(minutes)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Text("min")
                                        .font(.caption)
                                }
                                .foregroundColor(profile.dailyTimeCommitment == minutes ? .white : .primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    profile.dailyTimeCommitment == minutes
                                    ? themeManager.currentTheme.primaryColor
                                    : themeManager.currentTheme.cardColor
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            minutes == 30 ? themeManager.currentTheme.accentColor : Color.clear,
                                            lineWidth: minutes == 30 ? 2 : 0
                                        )
                                )
                            }
                        }
                    }
                }
                
                // Preferred Cleaning Days
                VStack(alignment: .leading, spacing: 12) {
                    Text("Preferred Cleaning Days")
                        .font(.headline)
                    
                    Text("Select the days you want to clean (we recommend 5 days)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        ForEach(1...7, id: \.self) { day in
                            Button {
                                if profile.preferredCleaningDays.contains(day) {
                                    profile.preferredCleaningDays.remove(day)
                                } else {
                                    profile.preferredCleaningDays.insert(day)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: profile.preferredCleaningDays.contains(day) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(
                                            profile.preferredCleaningDays.contains(day)
                                            ? themeManager.currentTheme.primaryColor
                                            : .gray
                                        )
                                    
                                    Text(dayName(for: day))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    if isWeekend(day) {
                                        Text("Weekend")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding()
                                .background(
                                    profile.preferredCleaningDays.contains(day)
                                    ? themeManager.currentTheme.primaryColor.opacity(0.1)
                                    : themeManager.currentTheme.cardColor
                                )
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Deep Cleaning Day
                VStack(alignment: .leading, spacing: 12) {
                    Text("Deep Cleaning Day")
                        .font(.headline)
                    
                    Text("Choose one day for weekly deep cleaning (60-90 minutes)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack(spacing: 8) {
                        ForEach([7, 1], id: \.self) { day in // Saturday, Sunday
                            Button {
                                profile.deepCleaningDay = day
                            } label: {
                                HStack {
                                    Image(systemName: profile.deepCleaningDay == day ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(
                                            profile.deepCleaningDay == day
                                            ? themeManager.currentTheme.primaryColor
                                            : .gray
                                        )
                                    
                                    Text(dayName(for: day))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Text("🧽 Deep Clean")
                                        .font(.caption)
                                        .foregroundColor(themeManager.currentTheme.accentColor)
                                }
                                .padding()
                                .background(
                                    profile.deepCleaningDay == day
                                    ? themeManager.currentTheme.primaryColor.opacity(0.1)
                                    : themeManager.currentTheme.cardColor
                                )
                                .cornerRadius(12)
                            }
                        }
                        
                        Button {
                            profile.deepCleaningDay = nil
                        } label: {
                            HStack {
                                Image(systemName: profile.deepCleaningDay == nil ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(
                                        profile.deepCleaningDay == nil
                                        ? themeManager.currentTheme.primaryColor
                                        : .gray
                                    )
                                
                                Text("No deep cleaning")
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("Just daily tasks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                profile.deepCleaningDay == nil
                                ? themeManager.currentTheme.primaryColor.opacity(0.1)
                                : themeManager.currentTheme.cardColor
                            )
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func dayName(for day: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[day - 1]
    }
    
    private func isWeekend(_ day: Int) -> Bool {
        day == 1 || day == 7 // Sunday or Saturday
    }
}

// MARK: - Step 3: Focus Areas

struct Step3FocusAreas: View {
    @Binding var profile: CleaningProfile
    @EnvironmentObject var themeManager: ThemeManager
    
    let highPriorityAreas: [CleaningArea] = [.kitchen, .bathroom, .livingRoom, .bedroom, .entryway]
    let mediumPriorityAreas: [CleaningArea] = [.office, .diningRoom, .laundry, .garage]
    let optionalAreas: [CleaningArea] = [.basement, .attic, .guestRoom, .outdoor]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Which areas need attention?")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select the areas you want to include in your cleaning schedule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // High Priority
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("High Priority")
                            .font(.headline)
                        Spacer()
                        Text("Cleaned more often")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Recommended: Kitchen and Bathroom")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                    
                    ForEach(highPriorityAreas) { area in
                        AreaSelectionRow(
                            area: area,
                            isSelected: profile.focusAreas.contains(area),
                            onToggle: { toggleArea(area) }
                        )
                    }
                }
                
                Divider()
                
                // Medium Priority
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Medium Priority")
                            .font(.headline)
                        Spacer()
                        Text("Regular cleaning")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(mediumPriorityAreas) { area in
                        AreaSelectionRow(
                            area: area,
                            isSelected: profile.focusAreas.contains(area),
                            onToggle: { toggleArea(area) }
                        )
                    }
                }
                
                Divider()
                
                // Optional Areas
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Optional Areas")
                            .font(.headline)
                        Spacer()
                        Text("As needed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(optionalAreas) { area in
                        AreaSelectionRow(
                            area: area,
                            isSelected: profile.focusAreas.contains(area),
                            onToggle: { toggleArea(area) }
                        )
                    }
                }
                
                // Summary
                if !profile.focusAreas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Areas")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(profile.focusAreas.count) areas selected")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }
    
    private func toggleArea(_ area: CleaningArea) {
        if profile.focusAreas.contains(area) {
            profile.focusAreas.removeAll { $0 == area }
        } else {
            profile.focusAreas.append(area)
        }
    }
}

struct AreaSelectionRow: View {
    let area: CleaningArea
    let isSelected: Bool
    let onToggle: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(isSelected ? themeManager.currentTheme.primaryColor : .gray)
                
                Image(systemName: area.icon)
                    .foregroundColor(themeManager.currentTheme.accentColor)
                    .frame(width: 24)
                
                Text(area.rawValue)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding()
            .background(
                isSelected
                ? themeManager.currentTheme.primaryColor.opacity(0.1)
                : themeManager.currentTheme.cardColor
            )
            .cornerRadius(12)
        }
    }
}

// MARK: - Step 4: Notifications

struct Step4Notifications: View {
    @Binding var profile: CleaningProfile
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedTime = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stay on track")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Set up reminders to help you maintain your cleaning routine")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Enable Notifications
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $profile.enableNotifications) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Cleaning Reminders")
                                .font(.headline)
                            Text("Get notified when it's time to clean")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(themeManager.currentTheme.primaryColor)
                    
                    if profile.enableNotifications {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reminder Time")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            DatePicker(
                                "Time",
                                selection: Binding(
                                    get: { profile.notificationTime ?? Date() },
                                    set: { profile.notificationTime = $0 }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            
                            Text("You'll receive a reminder at this time on your cleaning days")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(themeManager.currentTheme.cardColor)
                        .cornerRadius(12)
                    }
                }
                
                Divider()
                
                // Calendar Integration
                VStack(alignment: .leading, spacing: 12) {
                    Toggle(isOn: $profile.syncToCalendar) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Add to Apple Calendar")
                                .font(.headline)
                            Text("Cleaning tasks appear in your calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .tint(themeManager.currentTheme.primaryColor)
                    
                    if profile.syncToCalendar {
                        HStack(spacing: 8) {
                            Image(systemName: "info.circle")
                                .foregroundColor(themeManager.currentTheme.accentColor)
                            Text("Tasks will be synced to your default calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(themeManager.currentTheme.accentColor.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Divider()
                
                // Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notification Preview")
                        .font(.headline)
                    
                    NotificationPreviewCard(
                        profile: profile,
                        isEnabled: profile.enableNotifications
                    )
                }
            }
            .padding()
        }
    }
}

struct NotificationPreviewCard: View {
    let profile: CleaningProfile
    let isEnabled: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "app.badge")
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Text("RealLifeHQ")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                if let time = profile.notificationTime {
                    Text(time, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(isEnabled ? "🧹 Time to Clean!" : "Notifications Disabled")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(isEnabled ? "Your Kitchen Focus task is ready (30 min)" : "Enable notifications to receive reminders")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            isEnabled
            ? themeManager.currentTheme.cardColor
            : Color.gray.opacity(0.2)
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Step 5: Review & Customize

struct Step5Review: View {
    @Binding var profile: CleaningProfile
    let onComplete: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var weeklySchedule: [(day: String, task: String, duration: Int)] {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var schedule: [(day: String, task: String, duration: Int)] = []
        
        let sortedDays = profile.preferredCleaningDays.sorted()
        let dailyTasks = ["Kitchen Focus", "Bathroom Refresh", "Living Room Tidy", "Bedroom & Laundry", "Dusting & Vacuuming"]
        
        for (index, dayNum) in sortedDays.enumerated() {
            if index < dailyTasks.count {
                schedule.append((day: days[dayNum - 1], task: dailyTasks[index], duration: profile.dailyTimeCommitment))
            }
        }
        
        if let deepDay = profile.deepCleaningDay {
            // Replace or add deep clean
            let deepDayName = days[deepDay - 1]
            if let existingIndex = schedule.firstIndex(where: { $0.day == deepDayName }) {
                schedule[existingIndex] = (day: deepDayName, task: "Deep Clean Day 🧽", duration: 90)
            } else {
                schedule.append((day: deepDayName, task: "Deep Clean Day 🧽", duration: 90))
            }
        }
        
        return schedule.sorted { days.firstIndex(of: $0.day)! < days.firstIndex(of: $1.day)! }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your personalized schedule")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Review your weekly cleaning plan")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Summary Cards
                HStack(spacing: 12) {
                    SummaryCard(
                        title: "\(profile.preferredCleaningDays.count)",
                        subtitle: "Cleaning Days",
                        icon: "calendar",
                        color: themeManager.currentTheme.primaryColor
                    )
                    
                    SummaryCard(
                        title: "\(profile.dailyTimeCommitment)",
                        subtitle: "Minutes/Day",
                        icon: "clock.fill",
                        color: themeManager.currentTheme.accentColor
                    )
                    
                    SummaryCard(
                        title: "\(profile.focusAreas.count)",
                        subtitle: "Focus Areas",
                        icon: "house.fill",
                        color: .orange
                    )
                }
                
                // Weekly Schedule
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Schedule")
                        .font(.headline)
                    
                    ForEach(weeklySchedule, id: \.day) { item in
                        ScheduleRowCard(
                            day: item.day,
                            task: item.task,
                            duration: item.duration,
                            isDeepClean: item.task.contains("Deep Clean")
                        )
                    }
                    
                    // Rest Days
                    let restDays = (1...7).filter { !profile.preferredCleaningDays.contains($0) && profile.deepCleaningDay != $0 }
                    if !restDays.isEmpty {
                        ForEach(restDays, id: \.self) { dayNum in
                            let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                            RestDayCard(day: days[dayNum - 1])
                        }
                    }
                }
                
                // Notification Summary
                if profile.enableNotifications {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text("Notifications Enabled")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        
                        if let time = profile.notificationTime {
                            Text("Daily reminders at \(time, style: .time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Calendar Integration
                if profile.syncToCalendar {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.checkmark")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                        Text("Calendar sync enabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(themeManager.currentTheme.accentColor.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Start Button
                Button {
                    onComplete()
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Start Cleaning!")
                        Image(systemName: "sparkles")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
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
                    .cornerRadius(16)
                    .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.4), radius: 8, y: 4)
                }
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

struct SummaryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ScheduleRowCard: View {
    let day: String
    let task: String
    let duration: Int
    let isDeepClean: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(day)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                
                Spacer()
                
                if isDeepClean {
                    Text("🧽 Deep")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.currentTheme.accentColor)
                        .cornerRadius(6)
                }
            }
            
            Text(task)
                .font(.body)
            
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text("\(duration) minutes")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
}

struct RestDayCard: View {
    let day: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Text(day)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("💆 Rest Day")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        Step2Preferences(profile: .constant(CleaningProfile()))
            .environmentObject(ThemeManager())
    }
}
