import SwiftUI

// MARK: - Cleaning Schedule View
// Weekly schedule display with edit capabilities

struct CleaningScheduleView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var selectedWeekOffset = 0
    @State private var showingCustomizeSheet = false
    
    var currentWeekStart: Date {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return today
        }
        return calendar.date(byAdding: .weekOfYear, value: selectedWeekOffset, to: weekStart) ?? today
    }
    
    var weekSessions: [CleaningSession] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: currentWeekStart) else {
            return []
        }
        
        return dataManager.cleaningSessions
            .filter { $0.scheduledDate >= weekInterval.start && $0.scheduledDate < weekInterval.end }
            .sorted { $0.scheduledDate < $1.scheduledDate }
    }
    
    var weekTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: currentWeekStart)?.start,
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }
        
        if selectedWeekOffset == 0 {
            return "This Week"
        } else if selectedWeekOffset == 1 {
            return "Next Week"
        } else if selectedWeekOffset == -1 {
            return "Last Week"
        } else {
            return "Week of \(formatter.string(from: weekStart))"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Week Navigator
            weekNavigator
            
            // Schedule Content
            ScrollView {
                VStack(spacing: 16) {
                    if weekSessions.isEmpty {
                        emptyWeekView
                    } else {
                        ForEach(getDays(), id: \.self) { date in
                            DayScheduleCard(
                                date: date,
                                session: getSession(for: date),
                                task: getTask(for: date)
                            )
                        }
                    }
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
        }
        .navigationTitle("Weekly Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCustomizeSheet = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showingCustomizeSheet) {
            Text("Customize Schedule - Coming Soon")
        }
    }
    
    // MARK: - Week Navigator
    
    private var weekNavigator: some View {
        HStack {
            Button {
                withAnimation {
                    selectedWeekOffset -= 1
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(weekTitle)
                    .font(.headline)
                
                Text(weekDateRange)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                withAnimation {
                    selectedWeekOffset += 1
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .frame(width: 44, height: 44)
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
    }
    
    private var weekDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: currentWeekStart)?.start,
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            return ""
        }
        
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    // MARK: - Empty Week View
    
    private var emptyWeekView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Tasks This Week")
                .font(.headline)
            
            Text("Schedule will be generated when you complete setup")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - Helpers
    
    private func getDays() -> [Date] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: currentWeekStart)?.start else {
            return []
        }
        
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
        }
    }
    
    private func getSession(for date: Date) -> CleaningSession? {
        let calendar = Calendar.current
        return weekSessions.first { calendar.isDate($0.scheduledDate, inSameDayAs: date) }
    }
    
    private func getTask(for date: Date) -> CleaningTask? {
        guard let session = getSession(for: date) else { return nil }
        return dataManager.cleaningTasks.first { $0.id == session.taskId }
    }
}

// MARK: - Day Schedule Card

struct DayScheduleCard: View {
    let date: Date
    let session: CleaningSession?
    let task: CleaningTask?
    
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @State private var showingTaskDetail = false
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isPast: Bool {
        guard !isToday else { return false }
        return date < Date()
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        Button {
            if let session = session, let task = task, !session.isCompleted {
                showingTaskDetail = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dayName)
                            .font(.headline)
                            .foregroundColor(isToday ? themeManager.currentTheme.primaryColor : .primary)
                        
                        Text(dateString)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isToday {
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(themeManager.currentTheme.accentColor)
                            .cornerRadius(12)
                    }
                    
                    if let session = session {
                        statusBadge(for: session)
                    }
                }
                
                Divider()
                
                // Task Info
                if let session = session, let task = task {
                    HStack(spacing: 12) {
                        Image(systemName: task.area.icon)
                            .font(.title2)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                            .frame(width: 40, height: 40)
                            .background(themeManager.currentTheme.accentColor.opacity(0.15))
                            .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 12) {
                                Label("\(task.estimatedDuration) min", systemImage: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if task.isDeepClean {
                                    Label("Deep Clean", systemImage: "sparkles")
                                        .font(.caption)
                                        .foregroundColor(themeManager.currentTheme.accentColor)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if !session.isCompleted && !session.isSkipped {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Completed time
                    if session.isCompleted, let completedDate = session.completedDate {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Completed at \(completedDate, style: .time)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 4)
                    }
                } else {
                    // Rest Day
                    HStack {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Rest Day")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text("No cleaning scheduled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("💆")
                            .font(.title2)
                    }
                }
            }
            .padding()
            .background(cardBackground)
            .cornerRadius(16)
            .overlay(
                isToday
                ? RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.currentTheme.primaryColor, lineWidth: 2)
                : nil
            )
            .opacity(isPast && session?.isCompleted == false ? 0.6 : 1.0)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingTaskDetail) {
            if let session = session, let task = task {
                CleaningTaskDetailView(session: session, task: task)
            }
        }
    }
    
    private var cardBackground: some View {
        Group {
            if let session = session, session.isCompleted {
                Color.green.opacity(0.05)
            } else if isToday {
                LinearGradient(
                    colors: [
                        themeManager.currentTheme.cardColor,
                        themeManager.currentTheme.primaryColor.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                themeManager.currentTheme.cardColor
            }
        }
    }
    
    private func statusBadge(for session: CleaningSession) -> some View {
        Group {
            if session.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title3)
            } else if session.isSkipped {
                Image(systemName: "forward.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title3)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CleaningScheduleView()
            .environmentObject(ThemeManager())
            .environmentObject(DataManager())
    }
}
