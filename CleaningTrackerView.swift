import SwiftUI

// MARK: - Cleaning Tracker View
// Main dashboard for cleaning tracker

struct CleaningTrackerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingSetup = false
    
    var todaySession: CleaningSession? {
        dataManager.getTodaySession()
    }
    
    var upcomingSessions: [CleaningSession] {
        dataManager.getUpcomingSessions(limit: 5)
    }
    
    var thisWeekSessions: [CleaningSession] {
        dataManager.getThisWeekSessions()
    }
    
    var hasProfile: Bool {
        dataManager.cleaningProfile != nil
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if !hasProfile {
                    setupPrompt
                } else {
                    dashboardContent
                }
            }
            .navigationTitle("Cleaning Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink(destination: CleaningScheduleView()) {
                            Label("Weekly Schedule", systemImage: "calendar")
                        }
                        
                        NavigationLink(destination: CleaningStatisticsView()) {
                            Label("Statistics", systemImage: "chart.bar.fill")
                        }
                        
                        Button {
                            showingSetup = true
                        } label: {
                            Label("Edit Preferences", systemImage: "gearshape")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
            }
            .sheet(isPresented: $showingSetup) {
                CleaningSetupWizard()
            }
        }
    }
    
    // MARK: - Setup Prompt
    
    private var setupPrompt: some View {
        VStack(spacing: 24) {
            Spacer()
            
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
            
            VStack(spacing: 12) {
                Text("Welcome to Cleaning Tracker")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Create a personalized cleaning schedule in just a few steps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                CleaningFeatureRow(icon: "calendar.badge.checkmark", title: "Smart Scheduling", description: "30-minute daily routines")
                CleaningFeatureRow(icon: "bell.fill", title: "Daily Reminders", description: "Never forget to clean")
                CleaningFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Track Progress", description: "Build streaks & earn rewards")
                CleaningFeatureRow(icon: "sparkles", title: "Deep Cleaning", description: "Weekly thorough cleaning")
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(16)
            .padding(.horizontal)
            
            Button {
                showingSetup = true
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Get Started")
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
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Dashboard Content
    
    private var dashboardContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Today's Task Card
                if let session = todaySession {
                    TodayTaskCard(session: session)
                } else {
                    NoTaskTodayCard()
                }
                
                // This Week Progress
                ThisWeekProgressView(sessions: thisWeekSessions)
                
                // Streak Display
                StreakCard(statistics: dataManager.cleaningStatistics)
                
                // Upcoming Tasks
                if !upcomingSessions.isEmpty {
                    UpcomingTasksList(sessions: upcomingSessions)
                }
                
                // Quick Stats
                QuickStatsView(statistics: dataManager.cleaningStatistics)
            }
            .padding()
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
    }
}

// MARK: - Feature Row

struct CleaningFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Today Task Card

struct TodayTaskCard: View {
    let session: CleaningSession
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingTaskDetail = false
    
    var task: CleaningTask? {
        dataManager.cleaningTasks.first { $0.id == session.taskId }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Task")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(session.taskTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Image(systemName: session.taskArea.icon)
                    .font(.title)
                    .foregroundColor(themeManager.currentTheme.accentColor)
            }
            
            HStack(spacing: 16) {
                Label("\(task?.estimatedDuration ?? 30) min", systemImage: "clock.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label(session.taskArea.rawValue, systemImage: "mappin.circle.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let task = task {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Tasks:")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(task.subtasks.prefix(3)) { subtask in
                        HStack(spacing: 8) {
                            Image(systemName: "circle")
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                            Text(subtask.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if task.subtasks.count > 3 {
                        Text("+\(task.subtasks.count - 3) more tasks")
                            .font(.caption)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button {
                    showingTaskDetail = true
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Cleaning")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.currentTheme.primaryColor)
                    .cornerRadius(12)
                }
                
                Button {
                    skipTask()
                } label: {
                    Text("Skip")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    themeManager.currentTheme.cardColor,
                    themeManager.currentTheme.primaryColor.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, y: 4)
        .sheet(isPresented: $showingTaskDetail) {
            if let task = task {
                CleaningTaskDetailView(session: session, task: task)
            }
        }
    }
    
    private func skipTask() {
        dataManager.skipCleaningSession(session, reason: "Skipped from dashboard")
    }
}

// MARK: - No Task Today Card

struct NoTaskTodayCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("No cleaning today!")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Enjoy your rest day 💆")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
}

// MARK: - This Week Progress View

struct ThisWeekProgressView: View {
    let sessions: [CleaningSession]
    @EnvironmentObject var themeManager: ThemeManager
    
    var weekDays: [(day: String, session: CleaningSession?)] {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }
        
        let dayNames = ["S", "M", "T", "W", "T", "F", "S"]
        var days: [(String, CleaningSession?)] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: i, to: weekStart) else { continue }
            let session = sessions.first { calendar.isDate($0.scheduledDate, inSameDayAs: date) }
            days.append((dayNames[i], session))
        }
        
        return days
    }
    
    var completionCount: Int {
        sessions.filter { $0.isCompleted }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("This Week")
                    .font(.headline)
                
                Spacer()
                
                Text("\(completionCount)/\(sessions.count) done")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 8) {
                ForEach(weekDays, id: \.day) { day, session in
                    VStack(spacing: 8) {
                        Text(day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(circleColor(for: session))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Group {
                                    if session?.isCompleted == true {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    } else if session?.isToday == true {
                                        Circle()
                                            .stroke(themeManager.currentTheme.primaryColor, lineWidth: 2)
                                    }
                                }
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
    
    private func circleColor(for session: CleaningSession?) -> Color {
        guard let session = session else {
            return Color.gray.opacity(0.2)
        }
        
        if session.isCompleted {
            return themeManager.currentTheme.primaryColor
        } else if session.isSkipped {
            return Color.gray
        } else if session.isToday {
            return themeManager.currentTheme.accentColor
        } else {
            return Color.gray.opacity(0.3)
        }
    }
}

// MARK: - Streak Card

struct StreakCard: View {
    let statistics: CleaningStatistics
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Text("\(statistics.currentStreak)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text("days")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if statistics.currentStreak > 0 {
                        Text("🔥")
                            .font(.title)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("Best")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(statistics.longestStreak)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.currentTheme.accentColor)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    themeManager.currentTheme.primaryColor.opacity(0.1),
                    themeManager.currentTheme.accentColor.opacity(0.05)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - Upcoming Tasks List

struct UpcomingTasksList: View {
    let sessions: [CleaningSession]
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Tasks")
                .font(.headline)
            
            ForEach(sessions.filter { !$0.isToday }.prefix(3)) { session in
                UpcomingTaskRow(session: session)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
}

struct UpcomingTaskRow: View {
    let session: CleaningSession
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.taskArea.icon)
                .foregroundColor(themeManager.currentTheme.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.taskTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(session.scheduledDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Quick Stats View

struct QuickStatsView: View {
    let statistics: CleaningStatistics
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Stats")
                .font(.headline)
            
            HStack(spacing: 12) {
                CleaningStatCard(
                    title: "\(statistics.totalTasksCompleted)",
                    subtitle: "Tasks Done",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                CleaningStatCard(
                    title: "\(statistics.totalTimeSpent / 60)h",
                    subtitle: "Time Saved",
                    icon: "clock.fill",
                    color: .blue
                )
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
}

struct CleaningStatCard: View {
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
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Placeholder Views (implemented separately)
// CleaningScheduleView - See CleaningScheduleView.swift
// CleaningStatisticsView - See CleaningStatisticsView.swift  
// CleaningTaskDetailView - See CleaningTaskDetailView.swift

#Preview {
    CleaningTrackerView()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
