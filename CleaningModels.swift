import Foundation

// MARK: - Cleaning Profile
// Stores user's home information and preferences

struct CleaningProfile: Codable, Identifiable {
    var id = UUID()
    var homeType: HomeType
    var bedrooms: Int
    var bathrooms: Int
    var hasPets: Bool
    var petTypes: String?
    var householdSize: Int
    var dailyTimeCommitment: Int // minutes
    var preferredCleaningDays: Set<Int> // 1-7 (Sunday-Saturday)
    var deepCleaningDay: Int? // weekday
    var focusAreas: [CleaningArea]
    var createdDate: Date
    var notificationTime: Date?
    var enableNotifications: Bool
    var syncToCalendar: Bool
    
    enum HomeType: String, Codable, CaseIterable {
        case apartment = "Apartment"
        case house = "House"
        case condo = "Condo"
        case studio = "Studio"
        case other = "Other"
    }
    
    init() {
        self.id = UUID()
        self.homeType = .apartment
        self.bedrooms = 1
        self.bathrooms = 1
        self.hasPets = false
        self.householdSize = 1
        self.dailyTimeCommitment = 30
        self.preferredCleaningDays = [2, 3, 4, 5, 6] // Mon-Fri
        self.deepCleaningDay = 7 // Saturday
        self.focusAreas = [.kitchen, .bathroom]
        self.createdDate = Date()
        self.enableNotifications = true
        self.syncToCalendar = true
    }
}

// MARK: - Cleaning Area

enum CleaningArea: String, Codable, CaseIterable, Identifiable {
    case kitchen = "Kitchen"
    case bathroom = "Bathroom"
    case livingRoom = "Living Room"
    case bedroom = "Bedroom"
    case laundry = "Laundry"
    case entryway = "Entryway"
    case office = "Home Office"
    case diningRoom = "Dining Room"
    case garage = "Garage"
    case basement = "Basement"
    case attic = "Attic"
    case guestRoom = "Guest Room"
    case outdoor = "Outdoor"
    case other = "Other"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .kitchen: return "fork.knife"
        case .bathroom: return "shower.fill"
        case .livingRoom: return "sofa.fill"
        case .bedroom: return "bed.double.fill"
        case .laundry: return "washer.fill"
        case .entryway: return "door.left.hand.open"
        case .office: return "desktop.computer"
        case .diningRoom: return "fork.knife.circle.fill"
        case .garage: return "car.garage.closed"
        case .basement: return "stairs"
        case .attic: return "house.lodge.fill"
        case .guestRoom: return "bed.double"
        case .outdoor: return "tree.fill"
        case .other: return "square.grid.2x2"
        }
    }
    
    var priority: Priority {
        switch self {
        case .kitchen, .bathroom:
            return .high
        case .livingRoom, .bedroom, .entryway:
            return .medium
        default:
            return .low
        }
    }
}

// MARK: - Cleaning Task

struct CleaningTask: Codable, Identifiable, Hashable {
    var id = UUID()
    var title: String
    var area: CleaningArea
    var subtasks: [Subtask]
    var estimatedDuration: Int // minutes
    var frequency: CleaningFrequency
    var priority: Priority
    var isDeepClean: Bool
    var isCustom: Bool
    var dayOfWeek: Int? // 1-7, nil for non-weekly tasks
    var tips: String?
    
    struct Subtask: Codable, Identifiable, Hashable {
        var id = UUID()
        var title: String
        var isOptional: Bool
        
        init(title: String, isOptional: Bool = false) {
            self.id = UUID()
            self.title = title
            self.isOptional = isOptional
        }
    }
    
    init(title: String, area: CleaningArea, subtasks: [Subtask], estimatedDuration: Int, frequency: CleaningFrequency, priority: Priority, isDeepClean: Bool = false, isCustom: Bool = false, dayOfWeek: Int? = nil, tips: String? = nil) {
        self.id = UUID()
        self.title = title
        self.area = area
        self.subtasks = subtasks
        self.estimatedDuration = estimatedDuration
        self.frequency = frequency
        self.priority = priority
        self.isDeepClean = isDeepClean
        self.isCustom = isCustom
        self.dayOfWeek = dayOfWeek
        self.tips = tips
    }
}

// MARK: - Cleaning Session

struct CleaningSession: Codable, Identifiable {
    var id = UUID()
    var taskId: UUID
    var taskTitle: String
    var taskArea: CleaningArea
    var scheduledDate: Date
    var completedDate: Date?
    var actualDuration: Int? // minutes
    var isCompleted: Bool
    var isSkipped: Bool
    var skipReason: String?
    var completedSubtasks: Set<UUID>
    var notes: String?
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: scheduledDate)
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(scheduledDate)
    }
    
    var isPast: Bool {
        guard !isToday else { return false }
        return scheduledDate < Date()
    }
    
    var isFuture: Bool {
        guard !isToday else { return false }
        return scheduledDate > Date()
    }
    
    init(taskId: UUID, taskTitle: String, taskArea: CleaningArea, scheduledDate: Date) {
        self.id = UUID()
        self.taskId = taskId
        self.taskTitle = taskTitle
        self.taskArea = taskArea
        self.scheduledDate = scheduledDate
        self.isCompleted = false
        self.isSkipped = false
        self.completedSubtasks = []
    }
}

// MARK: - Cleaning Frequency

enum CleaningFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case custom = "Custom"
    
    var description: String {
        switch self {
        case .daily: return "Every day"
        case .weekly: return "Once per week"
        case .biweekly: return "Every 2 weeks"
        case .monthly: return "Once per month"
        case .custom: return "Custom schedule"
        }
    }
}

// MARK: - Priority

enum Priority: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

// MARK: - Cleaning Achievement

struct CleaningAchievement: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var type: AchievementType
    var requirement: Int // Days, tasks, etc.
    
    enum AchievementType: String, Codable {
        case firstClean = "First Clean"
        case weekWarrior = "Week Warrior"
        case deepDiver = "Deep Diver"
        case monthMaster = "Month Master"
        case speedCleaner = "Speed Cleaner"
        case perfectionist = "Perfectionist"
        case earlyBird = "Early Bird"
        case nightOwl = "Night Owl"
        case weekendWarrior = "Weekend Warrior"
    }
    
    static func createDefaultAchievements() -> [CleaningAchievement] {
        return [
            CleaningAchievement(
                title: "First Clean",
                description: "Complete your first cleaning task",
                icon: "star.fill",
                isUnlocked: false,
                type: .firstClean,
                requirement: 1
            ),
            CleaningAchievement(
                title: "Week Warrior",
                description: "Complete tasks for 7 days in a row",
                icon: "flame.fill",
                isUnlocked: false,
                type: .weekWarrior,
                requirement: 7
            ),
            CleaningAchievement(
                title: "Deep Diver",
                description: "Complete your first deep clean",
                icon: "sparkles",
                isUnlocked: false,
                type: .deepDiver,
                requirement: 1
            ),
            CleaningAchievement(
                title: "Month Master",
                description: "Complete 30 tasks in 30 days",
                icon: "calendar.circle.fill",
                isUnlocked: false,
                type: .monthMaster,
                requirement: 30
            ),
            CleaningAchievement(
                title: "Speed Cleaner",
                description: "Complete a task under estimated time",
                icon: "bolt.fill",
                isUnlocked: false,
                type: .speedCleaner,
                requirement: 1
            ),
            CleaningAchievement(
                title: "Early Bird",
                description: "Complete a task before 8 AM",
                icon: "sunrise.fill",
                isUnlocked: false,
                type: .earlyBird,
                requirement: 1
            ),
            CleaningAchievement(
                title: "Night Owl",
                description: "Complete a task after 8 PM",
                icon: "moon.stars.fill",
                isUnlocked: false,
                type: .nightOwl,
                requirement: 1
            )
        ]
    }
}

// MARK: - Cleaning Statistics

struct CleaningStatistics: Codable {
    var totalTasksCompleted: Int
    var totalTimeSpent: Int // minutes
    var currentStreak: Int
    var longestStreak: Int
    var lastCompletedDate: Date?
    var tasksByArea: [CleaningArea: Int]
    var monthlyCompletion: [String: Int] // "YYYY-MM": count
    
    init() {
        self.totalTasksCompleted = 0
        self.totalTimeSpent = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.tasksByArea = [:]
        self.monthlyCompletion = [:]
    }
    
    mutating func recordCompletion(area: CleaningArea, duration: Int, date: Date) {
        totalTasksCompleted += 1
        totalTimeSpent += duration
        
        // Update area count
        tasksByArea[area, default: 0] += 1
        
        // Update monthly count
        let monthKey = monthKey(for: date)
        monthlyCompletion[monthKey, default: 0] += 1
        
        // Update streak
        updateStreak(date: date)
    }
    
    mutating func updateStreak(date: Date) {
        let calendar = Calendar.current
        
        if let lastDate = lastCompletedDate {
            let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: lastDate), to: calendar.startOfDay(for: date)).day ?? 0
            
            if daysDiff == 0 {
                // Same day, no change
                return
            } else if daysDiff == 1 {
                // Consecutive day
                currentStreak += 1
            } else {
                // Streak broken
                currentStreak = 1
            }
        } else {
            currentStreak = 1
        }
        
        lastCompletedDate = date
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    private func monthKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: date)
    }
}
