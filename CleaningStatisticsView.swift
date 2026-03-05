import SwiftUI

// MARK: - Cleaning Statistics View
// Progress dashboard with achievements and analytics

struct CleaningStatisticsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedTab: StatTab = .overview
    
    enum StatTab: String, CaseIterable {
        case overview = "Overview"
        case achievements = "Achievements"
        case history = "History"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            tabSelector
            
            // Content
            ScrollView {
                VStack(spacing: 20) {
                    switch selectedTab {
                    case .overview:
                        overviewContent
                    case .achievements:
                        achievementsContent
                    case .history:
                        historyContent
                    }
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Tab Selector
    
    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(StatTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedTab == tab ? themeManager.currentTheme.primaryColor : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedTab == tab
                            ? themeManager.currentTheme.primaryColor.opacity(0.1)
                            : Color.clear
                        )
                        .overlay(
                            Rectangle()
                                .fill(selectedTab == tab ? themeManager.currentTheme.primaryColor : Color.clear)
                                .frame(height: 3),
                            alignment: .bottom
                        )
                }
            }
        }
        .background(themeManager.currentTheme.cardColor)
    }
    
    // MARK: - Overview Content
    
    private var overviewContent: some View {
        VStack(spacing: 20) {
            // Monthly Summary
            monthlySummaryCard
            
            // Completion by Area
            completionByAreaCard
            
            // Streak Information
            streakCard
            
            // Time Stats
            timeStatsCard
        }
    }
    
    private var monthlySummaryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Month")
                .font(.headline)
            
            let monthKey = getCurrentMonthKey()
            let monthlyCount = dataManager.cleaningStatistics.monthlyCompletion[monthKey] ?? 0
            let totalTasks = dataManager.cleaningSessions.filter { session in
                let sessionMonthKey = getMonthKey(for: session.scheduledDate)
                return sessionMonthKey == monthKey
            }.count
            
            let percentage = totalTasks > 0 ? Double(monthlyCount) / Double(totalTasks) : 0.0
            
            HStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tasks Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(alignment: .bottom, spacing: 8) {
                        Text("\(monthlyCount)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        Text("/ \(totalTasks)")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: percentage,
                    lineWidth: 12,
                    color: themeManager.currentTheme.primaryColor
                )
                .frame(width: 80, height: 80)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.currentTheme.primaryColor,
                                    themeManager.currentTheme.accentColor
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
    
    private var completionByAreaCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completion by Area")
                .font(.headline)
            
            if dataManager.cleaningStatistics.tasksByArea.isEmpty {
                Text("No data yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                let sortedAreas = dataManager.cleaningStatistics.tasksByArea.sorted { $0.value > $1.value }
                
                ForEach(sortedAreas.prefix(5), id: \.key) { area, count in
                    AreaProgressRow(
                        area: area,
                        count: count,
                        total: dataManager.cleaningStatistics.totalTasksCompleted
                    )
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
    
    private var streakCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Streaks")
                .font(.headline)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("\(dataManager.cleaningStatistics.currentStreak)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        
                        if dataManager.cleaningStatistics.currentStreak > 0 {
                            Text("🔥")
                                .font(.title)
                        }
                    }
                    
                    Text("days in a row")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Divider()
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("Best Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Text("🏆")
                            .font(.title)
                        
                        Text("\(dataManager.cleaningStatistics.longestStreak)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                    
                    Text("personal best")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    themeManager.currentTheme.primaryColor.opacity(0.1),
                    themeManager.currentTheme.accentColor.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    private var timeStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time Stats")
                .font(.headline)
            
            HStack(spacing: 16) {
                TimeStatBox(
                    icon: "clock.fill",
                    value: "\(dataManager.cleaningStatistics.totalTimeSpent / 60)",
                    unit: "hours",
                    label: "Total Time",
                    color: .blue
                )
                
                TimeStatBox(
                    icon: "chart.bar.fill",
                    value: "\(dataManager.cleaningStatistics.totalTasksCompleted)",
                    unit: "tasks",
                    label: "Completed",
                    color: .green
                )
            }
            
            if dataManager.cleaningStatistics.totalTasksCompleted > 0 {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    Text("Average: \(dataManager.cleaningStatistics.totalTimeSpent / dataManager.cleaningStatistics.totalTasksCompleted) min per task")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
    
    // MARK: - Achievements Content
    
    private var achievementsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Achievements")
                .font(.title3)
                .fontWeight(.bold)
            
            let unlocked = dataManager.cleaningAchievements.filter { $0.isUnlocked }
            let locked = dataManager.cleaningAchievements.filter { !$0.isUnlocked }
            
            Text("\(unlocked.count) of \(dataManager.cleaningAchievements.count) unlocked")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Unlocked Achievements
            if !unlocked.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Unlocked")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    ForEach(unlocked) { achievement in
                        AchievementCard(achievement: achievement, isUnlocked: true)
                    }
                }
            }
            
            // Locked Achievements
            if !locked.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Locked")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    ForEach(locked) { achievement in
                        AchievementCard(achievement: achievement, isUnlocked: false)
                    }
                }
                .padding(.top)
            }
        }
    }
    
    // MARK: - History Content
    
    private var historyContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title3)
                .fontWeight(.bold)
            
            let completedSessions = dataManager.cleaningSessions
                .filter { $0.isCompleted }
                .sorted { ($0.completedDate ?? Date.distantPast) > ($1.completedDate ?? Date.distantPast) }
            
            if completedSessions.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("No history yet")
                        .font(.headline)
                    
                    Text("Complete your first task to see it here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                ForEach(completedSessions.prefix(20)) { session in
                    HistoryRow(session: session)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func getCurrentMonthKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
    
    private func getMonthKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Components

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.headline)
                .fontWeight(.bold)
        }
    }
}

struct AreaProgressRow: View {
    let area: CleaningArea
    let count: Int
    let total: Int
    @EnvironmentObject var themeManager: ThemeManager
    
    var percentage: Double {
        total > 0 ? Double(count) / Double(total) : 0.0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: area.icon)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                        .frame(width: 20)
                    
                    Text(area.rawValue)
                        .font(.subheadline)
                }
                
                Spacer()
                
                Text("\(count) tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.currentTheme.accentColor)
                        .frame(width: geometry.size.width * percentage, height: 6)
                }
            }
            .frame(height: 6)
        }
    }
}

struct TimeStatBox: View {
    let icon: String
    let value: String
    let unit: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let achievement: CleaningAchievement
    let isUnlocked: Bool
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.title)
                .foregroundColor(isUnlocked ? .yellow : .gray)
                .frame(width: 50, height: 50)
                .background(isUnlocked ? Color.yellow.opacity(0.2) : Color.gray.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let unlockedDate = achievement.unlockedDate {
                    Text("Unlocked \(unlockedDate, style: .date)")
                        .font(.caption2)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                }
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(isUnlocked ? themeManager.currentTheme.cardColor : Color.gray.opacity(0.05))
        .cornerRadius(12)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

struct HistoryRow: View {
    let session: CleaningSession
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.taskArea.icon)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 40, height: 40)
                .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.taskTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let completedDate = session.completedDate {
                    Text(completedDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let duration = session.actualDuration {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(duration) min")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        CleaningStatisticsView()
            .environmentObject(ThemeManager())
            .environmentObject(DataManager())
    }
}
