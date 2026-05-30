import SwiftUI

// MARK: - Step 2: Time & Days
// (Shown as Step 2 in the wizard)

struct Step2Preferences: View {
    @Binding var profile: CleaningProfile
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Set your schedule")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("How much time can you commit, and which days work best?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Daily Time Commitment
                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily Time Commitment")
                        .font(.headline)

                    Text("Recommended: 30 minutes for a sustainable routine")
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
                    Text("Cleaning Days")
                        .font(.headline)

                    Text("Select the days you want to clean")
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
                                    Image(systemName: profile.preferredCleaningDays.contains(day)
                                          ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(
                                            profile.preferredCleaningDays.contains(day)
                                            ? themeManager.currentTheme.primaryColor : .gray
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

                    Text("Pick one day for a thorough clean (60–90 minutes)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    VStack(spacing: 8) {
                        ForEach(1...7, id: \.self) { day in
                            Button {
                                profile.deepCleaningDay = day
                            } label: {
                                HStack {
                                    Image(systemName: profile.deepCleaningDay == day
                                          ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(
                                            profile.deepCleaningDay == day
                                            ? themeManager.currentTheme.primaryColor : .gray
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
                                Image(systemName: profile.deepCleaningDay == nil
                                      ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(
                                        profile.deepCleaningDay == nil
                                        ? themeManager.currentTheme.primaryColor : .gray
                                    )

                                Text("No deep cleaning day")
                                    .foregroundColor(.primary)

                                Spacer()

                                Text("Daily tasks only")
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
        day == 1 || day == 7
    }
}

// MARK: - Step 3: Focus Areas (Rooms)
// (Shown as Step 1 in the wizard)

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
                    Text("Which rooms do you want to clean?")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Select every area you want included in your schedule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                areaGroup(
                    title: "Main Rooms",
                    note: "Recommended starting point",
                    areas: highPriorityAreas
                )

                Divider()

                areaGroup(
                    title: "Additional Rooms",
                    note: "Add if you use them regularly",
                    areas: mediumPriorityAreas
                )

                Divider()

                areaGroup(
                    title: "Other Areas",
                    note: "Include as needed",
                    areas: optionalAreas
                )

                if !profile.focusAreas.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        Text("\(profile.focusAreas.count) room\(profile.focusAreas.count == 1 ? "" : "s") selected")
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

    @ViewBuilder
    private func areaGroup(title: String, note: String, areas: [CleaningArea]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ForEach(areas) { area in
                AreaSelectionRow(
                    area: area,
                    isSelected: profile.focusAreas.contains(area),
                    onToggle: { toggleArea(area) }
                )
            }
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

// MARK: - Step 4: Reminders (Premium-Gated)
// (Shown as Step 3 in the wizard)

struct Step4Notifications: View {
    @Binding var profile: CleaningProfile
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(SubscriptionManager.self) private var subscriptionManager

    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stay on track")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Set up reminders to keep your cleaning routine going")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if subscriptionManager.currentPlan == .free {
                    // Premium upsell
                    premiumGate
                } else {
                    // Full notification settings
                    notificationSettings
                }
            }
            .padding()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: Premium Gate

    private var premiumGate: some View {
        VStack(spacing: 20) {
            // Lock icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.primaryColor,
                                themeManager.currentTheme.accentColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)

            VStack(spacing: 8) {
                Text("Cleaning Reminders")
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Premium Feature")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(themeManager.currentTheme.primaryColor)
                    .cornerRadius(8)
            }

            Text("Upgrade to Premium to get daily cleaning reminders and Apple Calendar sync so you never miss a task.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // Feature bullets
            VStack(alignment: .leading, spacing: 12) {
                reminderFeatureRow(
                    icon: "bell.fill",
                    text: "Daily reminders at your chosen time"
                )
                reminderFeatureRow(
                    icon: "calendar.badge.checkmark",
                    text: "Sync cleaning tasks to Apple Calendar"
                )
                reminderFeatureRow(
                    icon: "repeat",
                    text: "Reminders on every scheduled cleaning day"
                )
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)

            Button {
                showPaywall = true
            } label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text("Unlock Premium")
                        .fontWeight(.semibold)
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
                .cornerRadius(14)
            }

            Text("You can skip this step and add reminders later after upgrading.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: 1)
        )
    }

    private func reminderFeatureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }

    // MARK: Full Notification Settings (Premium)

    private var notificationSettings: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Daily Reminders toggle
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

            // Calendar Sync toggle
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

            // Notification preview
            VStack(alignment: .leading, spacing: 12) {
                Text("Notification Preview")
                    .font(.headline)

                NotificationPreviewCard(
                    profile: profile,
                    isEnabled: profile.enableNotifications
                )
            }
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

            Text(isEnabled
                 ? "Your Kitchen Focus task is ready (\(profile.dailyTimeCommitment) min)"
                 : "Enable notifications to receive reminders")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(isEnabled ? themeManager.currentTheme.cardColor : Color.gray.opacity(0.2))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Step 5: Review & Start
// (Shown as Step 4 in the wizard)

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
                    Text("Your cleaning schedule")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Here's what we've set up for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                // Summary stats
                HStack(spacing: 12) {
                    SummaryCard(
                        title: "\(profile.preferredCleaningDays.count)",
                        subtitle: "Cleaning Days",
                        icon: "calendar",
                        color: themeManager.currentTheme.primaryColor
                    )

                    SummaryCard(
                        title: "\(profile.dailyTimeCommitment)",
                        subtitle: "Min / Day",
                        icon: "clock.fill",
                        color: themeManager.currentTheme.accentColor
                    )

                    SummaryCard(
                        title: "\(profile.focusAreas.count)",
                        subtitle: "Rooms",
                        icon: "house.fill",
                        color: .orange
                    )
                }

                // Weekly schedule
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

                    let restDays = (1...7).filter {
                        !profile.preferredCleaningDays.contains($0) && profile.deepCleaningDay != $0
                    }
                    if !restDays.isEmpty {
                        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                        ForEach(restDays, id: \.self) { dayNum in
                            RestDayCard(day: days[dayNum - 1])
                        }
                    }
                }

                // Rooms summary
                if !profile.focusAreas.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rooms Included")
                            .font(.headline)

                        FlowLayout(spacing: 8) {
                            ForEach(profile.focusAreas) { area in
                                HStack(spacing: 4) {
                                    Image(systemName: area.icon)
                                        .font(.caption)
                                    Text(area.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(themeManager.currentTheme.primaryColor.opacity(0.12))
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .cornerRadius(20)
                            }
                        }
                    }
                }

                // Notification summary
                if profile.enableNotifications {
                    HStack(spacing: 8) {
                        Image(systemName: "bell.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reminders On")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            if let time = profile.notificationTime {
                                Text("Daily at \(time, style: .time)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .cornerRadius(12)
                }

                // Start button
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

// MARK: - Flow Layout (for room tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.frames[index].minX + bounds.minX,
                                      y: result.frames[index].minY + bounds.minY),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth, x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                frames.append(CGRect(x: x, y: y, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                maxX = max(maxX, x + size.width)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxX, height: y + lineHeight)
        }
    }
}

// MARK: - Supporting Cards

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
