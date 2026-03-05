import SwiftUI

// MARK: - Cleaning Task Detail View
// Active task screen with subtask checklist and timer

struct CleaningTaskDetailView: View {
    let session: CleaningSession
    let task: CleaningTask
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var completedSubtasks: Set<UUID> = []
    @State private var startTime: Date?
    @State private var elapsedTime: Int = 0
    @State private var timer: Timer?
    @State private var showingCompleteConfirmation = false
    @State private var showingSkipConfirmation = false
    @State private var showingCelebration = false
    @State private var actualDuration: Int = 0
    
    var progress: Double {
        guard !task.subtasks.isEmpty else { return 0 }
        return Double(completedSubtasks.count) / Double(task.subtasks.count)
    }
    
    var isStarted: Bool {
        startTime != nil
    }
    
    var formattedElapsedTime: String {
        let minutes = elapsedTime / 60
        let seconds = elapsedTime % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    taskHeaderCard
                    
                    // Timer Section
                    if isStarted {
                        timerSection
                    }
                    
                    // Progress Bar
                    progressSection
                    
                    // Subtasks Checklist
                    subtasksSection
                    
                    // Tips Section
                    if let tips = task.tips {
                        tipsSection(tips)
                    }
                    
                    // Action Buttons
                    actionButtons
                }
                .padding()
            }
            .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
            .navigationTitle(task.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        stopTimer()
                        dismiss()
                    }
                }
            }
            .onAppear {
                completedSubtasks = session.completedSubtasks
            }
            .alert("Task Complete!", isPresented: $showingCompleteConfirmation) {
                Button("Finish") {
                    completeTask()
                }
                Button("Keep Cleaning", role: .cancel) { }
            } message: {
                Text("Great job! You've completed all tasks in \(formattedElapsedTime).")
            }
            .alert("Skip This Task?", isPresented: $showingSkipConfirmation) {
                Button("Skip", role: .destructive) {
                    skipTask()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("You can always come back to this later.")
            }
            .sheet(isPresented: $showingCelebration) {
                CelebrationView(
                    taskTitle: task.title,
                    duration: actualDuration,
                    streak: dataManager.cleaningStatistics.currentStreak
                )
            }
        }
    }
    
    // MARK: - Task Header Card
    
    private var taskHeaderCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: task.area.icon)
                    .font(.title)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .frame(width: 50, height: 50)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.area.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(task.title)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                Label("\(task.estimatedDuration) min", systemImage: "clock.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Label("\(task.subtasks.count) tasks", systemImage: "checklist")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if task.isDeepClean {
                    Label("Deep Clean", systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(themeManager.currentTheme.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(themeManager.currentTheme.accentColor.opacity(0.15))
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
    
    // MARK: - Timer Section
    
    private var timerSection: some View {
        VStack(spacing: 12) {
            Text("Time Spent")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formattedElapsedTime)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            if elapsedTime > task.estimatedDuration * 60 {
                Text("Over estimated time")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else {
                let remaining = (task.estimatedDuration * 60) - elapsedTime
                Text("\(remaining / 60) min remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
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
    
    // MARK: - Progress Section
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.headline)
                
                Spacer()
                
                Text("\(completedSubtasks.count)/\(task.subtasks.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
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
                        .frame(width: geometry.size.width * progress, height: 12)
                        .animation(.spring(), value: progress)
                }
            }
            .frame(height: 12)
            
            if progress == 1.0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("All tasks complete!")
                        .font(.caption)
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
    
    // MARK: - Subtasks Section
    
    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Checklist")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(task.subtasks) { subtask in
                    SubtaskRow(
                        subtask: subtask,
                        isCompleted: completedSubtasks.contains(subtask.id),
                        onToggle: {
                            toggleSubtask(subtask)
                        }
                    )
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.cardColor)
        .cornerRadius(16)
    }
    
    // MARK: - Tips Section
    
    private func tipsSection(_ tips: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Pro Tip")
                    .font(.headline)
            }
            
            Text(tips)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(16)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !isStarted {
                // Start Button
                Button {
                    startCleaning()
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Cleaning")
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
            } else {
                // Mark Complete Button
                Button {
                    if progress == 1.0 {
                        showingCompleteConfirmation = true
                    } else {
                        completeTask()
                    }
                } label: {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text(progress == 1.0 ? "Finish Cleaning" : "Mark as Complete")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        progress == 1.0
                        ? LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            colors: [
                                themeManager.currentTheme.primaryColor,
                                themeManager.currentTheme.accentColor
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
            }
            
            HStack(spacing: 12) {
                // Need More Time
                if isStarted {
                    Button {
                        // Just continue - no action needed
                    } label: {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                            Text("Keep Going")
                        }
                        .font(.subheadline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                        .cornerRadius(12)
                    }
                }
                
                // Skip Button
                Button {
                    showingSkipConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "forward.fill")
                        Text("Skip")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func startCleaning() {
        startTime = Date()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func toggleSubtask(_ subtask: CleaningTask.Subtask) {
        if completedSubtasks.contains(subtask.id) {
            completedSubtasks.remove(subtask.id)
        } else {
            completedSubtasks.insert(subtask.id)
            
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            // Auto-start timer on first subtask
            if !isStarted {
                startCleaning()
            }
        }
    }
    
    private func completeTask() {
        stopTimer()
        actualDuration = elapsedTime / 60
        
        var updatedSession = session
        updatedSession.completedSubtasks = completedSubtasks
        
        dataManager.completeCleaningSession(updatedSession, duration: actualDuration)
        
        showingCelebration = true
        
        // Dismiss after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            dismiss()
        }
    }
    
    private func skipTask() {
        stopTimer()
        dataManager.skipCleaningSession(session, reason: "Skipped from task detail")
        dismiss()
    }
}

// MARK: - Subtask Row

struct SubtaskRow: View {
    let subtask: CleaningTask.Subtask
    let isCompleted: Bool
    let onToggle: () -> Void
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? .green : .gray)
                
                Text(subtask.title)
                    .font(.body)
                    .foregroundColor(isCompleted ? .secondary : .primary)
                    .strikethrough(isCompleted)
                
                Spacer()
                
                if subtask.isOptional {
                    Text("Optional")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .padding()
            .background(isCompleted ? Color.green.opacity(0.05) : Color.clear)
            .cornerRadius(12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Celebration View

struct CelebrationView: View {
    let taskTitle: String
    let duration: Int
    let streak: Int
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var confettiCounter = 0
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Celebration Icon with animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.currentTheme.primaryColor.opacity(0.3),
                                    themeManager.currentTheme.accentColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
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
                }
                .confettiCannon(counter: $confettiCounter, num: 50, radius: 400)
                
                VStack(spacing: 12) {
                    Text("Task Complete!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(taskTitle)
                        .font(.title3)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text("Finished in \(duration) minutes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Stats
                HStack(spacing: 32) {
                    VStack(spacing: 4) {
                        Text("\(streak)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        Text("Day Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("🔥")
                            .font(.title)
                        Text("On Fire!")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(themeManager.currentTheme.cardColor)
                .cornerRadius(16)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            confettiCounter += 1
            
            // Haptic celebration
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - Confetti Modifier (Simple Implementation)

extension View {
    func confettiCannon(counter: Binding<Int>, num: Int, radius: CGFloat) -> some View {
        self.overlay(
            ZStack {
                ForEach(0..<num, id: \.self) { _ in
                    ConfettiPiece()
                }
            }
            .opacity(counter.wrappedValue > 0 ? 1 : 0)
        )
    }
}

struct ConfettiPiece: View {
    @State private var location = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
    @State private var opacity: Double = 1
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]
    let randomColor: Color
    
    init() {
        randomColor = colors.randomElement() ?? .blue
    }
    
    var body: some View {
        Circle()
            .fill(randomColor)
            .frame(width: 10, height: 10)
            .position(location)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 2.0)) {
                    location = CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: UIScreen.main.bounds.height + 100
                    )
                    opacity = 0
                }
            }
    }
}

#Preview {
    let session = CleaningSession(
        taskId: UUID(),
        taskTitle: "Kitchen Focus",
        taskArea: .kitchen,
        scheduledDate: Date()
    )
    
    let task = CleaningTaskTemplates.kitchenFocus()
    
    return CleaningTaskDetailView(session: session, task: task)
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
