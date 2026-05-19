import Foundation

// MARK: - Cleaning Task Templates
// Pre-defined cleaning tasks and schedules

class CleaningTaskTemplates {
    
    // MARK: - Daily Cleaning Tasks (30 minutes)
    
    static func kitchenFocus() -> CleaningTask {
        CleaningTask(
            title: "Kitchen Focus",
            area: .kitchen,
            subtasks: [
                .init(title: "Wipe down countertops and backsplash"),
                .init(title: "Clean sink and faucet"),
                .init(title: "Wipe appliance exteriors (microwave, stove, fridge)"),
                .init(title: "Sweep or vacuum floor"),
                .init(title: "Take out trash and recycling")
            ],
            estimatedDuration: 30,
            frequency: .weekly,
            priority: .high,
            tips: "Work top to bottom for efficient cleaning. Keep a spray bottle handy for quick wipe-downs."
        )
    }
    
    static func bathroomRefresh() -> CleaningTask {
        CleaningTask(
            title: "Bathroom Refresh",
            area: .bathroom,
            subtasks: [
                .init(title: "Clean toilet bowl and exterior"),
                .init(title: "Wipe down sink and faucet"),
                .init(title: "Clean mirrors and glass"),
                .init(title: "Wipe shower/tub surfaces"),
                .init(title: "Sweep or vacuum floor"),
                .init(title: "Replace towels if needed", isOptional: true)
            ],
            estimatedDuration: 30,
            frequency: .weekly,
            priority: .high,
            tips: "Let cleaners sit for a few minutes before wiping for better results."
        )
    }
    
    static func livingRoomTidy() -> CleaningTask {
        CleaningTask(
            title: "Living Room Tidy",
            area: .livingRoom,
            subtasks: [
                .init(title: "Pick up and organize items"),
                .init(title: "Dust surfaces and shelves"),
                .init(title: "Fluff and arrange pillows/cushions"),
                .init(title: "Vacuum or sweep floor"),
                .init(title: "Wipe down coffee table and TV stand")
            ],
            estimatedDuration: 30,
            frequency: .weekly,
            priority: .medium,
            tips: "Keep a basket for quick item collection. Vacuum in one direction for even coverage."
        )
    }
    
    static func bedroomLaundry() -> CleaningTask {
        CleaningTask(
            title: "Bedroom & Laundry",
            area: .bedroom,
            subtasks: [
                .init(title: "Make bed and straighten linens"),
                .init(title: "Put away clothes and shoes"),
                .init(title: "Dust nightstands and dressers"),
                .init(title: "Vacuum or sweep floor"),
                .init(title: "Start a load of laundry", isOptional: true)
            ],
            estimatedDuration: 30,
            frequency: .weekly,
            priority: .medium,
            tips: "Making your bed first thing sets a positive tone for the day."
        )
    }
    
    static func dustingVacuuming() -> CleaningTask {
        CleaningTask(
            title: "Dusting & Vacuuming",
            area: .livingRoom,
            subtasks: [
                .init(title: "Dust all surfaces, shelves, and electronics"),
                .init(title: "Dust ceiling fans and light fixtures"),
                .init(title: "Vacuum all carpeted areas"),
                .init(title: "Vacuum/sweep hard floors"),
                .init(title: "Clean air vents", isOptional: true)
            ],
            estimatedDuration: 30,
            frequency: .weekly,
            priority: .medium,
            tips: "Dust before vacuuming to catch falling debris. Use microfiber cloths for best results."
        )
    }
    
    // MARK: - Deep Cleaning Tasks (60-90 minutes)
    
    static func deepCleanKitchen() -> CleaningTask {
        CleaningTask(
            title: "Deep Clean: Kitchen",
            area: .kitchen,
            subtasks: [
                .init(title: "Clean inside refrigerator and freezer"),
                .init(title: "Deep clean oven and stovetop"),
                .init(title: "Clean inside microwave"),
                .init(title: "Organize and wipe down cabinets"),
                .init(title: "Clean under appliances"),
                .init(title: "Mop floors thoroughly"),
                .init(title: "Clean light fixtures and windows")
            ],
            estimatedDuration: 90,
            frequency: .monthly,
            priority: .high,
            isDeepClean: true,
            tips: "Remove refrigerator items the night before. Use baking soda paste for stubborn oven stains."
        )
    }
    
    static func deepCleanBathroom() -> CleaningTask {
        CleaningTask(
            title: "Deep Clean: Bathroom",
            area: .bathroom,
            subtasks: [
                .init(title: "Scrub shower/tub including grout"),
                .init(title: "Deep clean toilet"),
                .init(title: "Clean exhaust fan"),
                .init(title: "Organize and clean cabinets/drawers"),
                .init(title: "Wash bath mats and shower curtain"),
                .init(title: "Scrub and mop floor"),
                .init(title: "Clean mirrors and light fixtures")
            ],
            estimatedDuration: 60,
            frequency: .monthly,
            priority: .high,
            isDeepClean: true,
            tips: "Spray cleaner and let sit while you clean other areas. Use an old toothbrush for grout."
        )
    }
    
    static func deepCleanLivingAreas() -> CleaningTask {
        CleaningTask(
            title: "Deep Clean: Living Areas",
            area: .livingRoom,
            subtasks: [
                .init(title: "Move furniture and vacuum underneath"),
                .init(title: "Wash windows and window sills"),
                .init(title: "Deep clean upholstery/furniture"),
                .init(title: "Dust and wipe baseboards"),
                .init(title: "Clean light fixtures and ceiling fans"),
                .init(title: "Organize closets and storage"),
                .init(title: "Steam clean carpets or mop floors")
            ],
            estimatedDuration: 90,
            frequency: .monthly,
            priority: .medium,
            isDeepClean: true,
            tips: "Work room by room. Take before/after photos for motivation!"
        )
    }
    
    static func deepCleanBedrooms() -> CleaningTask {
        CleaningTask(
            title: "Deep Clean: Bedrooms",
            area: .bedroom,
            subtasks: [
                .init(title: "Wash all bedding including mattress pad"),
                .init(title: "Flip or rotate mattress"),
                .init(title: "Vacuum under bed"),
                .init(title: "Clean out and organize closets"),
                .init(title: "Dust ceiling fans and light fixtures"),
                .init(title: "Wipe down baseboards and doors"),
                .init(title: "Vacuum/mop floors thoroughly")
            ],
            estimatedDuration: 60,
            frequency: .monthly,
            priority: .medium,
            isDeepClean: true,
            tips: "Declutter first - donate items you no longer use. Vacuum mattress while bedding is washing."
        )
    }
    
    // MARK: - Quick Tasks (15 minutes)
    
    static func quickEntryway() -> CleaningTask {
        CleaningTask(
            title: "Entryway Quick Clean",
            area: .entryway,
            subtasks: [
                .init(title: "Organize shoes and coats"),
                .init(title: "Wipe down surfaces"),
                .init(title: "Sweep or vacuum floor"),
                .init(title: "Clean door handles and light switches")
            ],
            estimatedDuration: 15,
            frequency: .weekly,
            priority: .medium,
            tips: "First impressions matter! A clean entryway sets the tone."
        )
    }
    
    // MARK: - Generate Weekly Schedule
    
    static func generateWeeklySchedule(profile: CleaningProfile) -> [Int: CleaningTask] {
        var schedule: [Int: CleaningTask] = [:]
        let sortedDays = profile.preferredCleaningDays.sorted()
        
        // Standard rotation for 5-day schedule
        let dailyTasks: [CleaningTask] = [
            kitchenFocus(),
            bathroomRefresh(),
            livingRoomTidy(),
            bedroomLaundry(),
            dustingVacuuming()
        ]
        
        // Assign daily tasks to preferred days
        for (index, day) in sortedDays.enumerated() {
            if index < dailyTasks.count {
                var task = dailyTasks[index]
                task.dayOfWeek = day
                schedule[day] = task
            }
        }
        
        // Add deep cleaning on the designated day
        if let deepDay = profile.deepCleaningDay {
            var deepTask = selectDeepCleanTask(for: profile)
            deepTask.dayOfWeek = deepDay
            schedule[deepDay] = deepTask
        }
        
        return schedule
    }
    
    private static func selectDeepCleanTask(for profile: CleaningProfile) -> CleaningTask {
        // Rotate through deep cleaning tasks based on focus areas
        let deepTasks: [CleaningTask] = [
            deepCleanKitchen(),
            deepCleanBathroom(),
            deepCleanLivingAreas(),
            deepCleanBedrooms()
        ]
        
        // Filter by user's focus areas
        let relevantTasks = deepTasks.filter { task in
            profile.focusAreas.contains(task.area)
        }
        
        return relevantTasks.first ?? deepCleanKitchen()
    }
    
    // MARK: - Get All Templates
    
    static func getAllDailyTasks() -> [CleaningTask] {
        return [
            kitchenFocus(),
            bathroomRefresh(),
            livingRoomTidy(),
            bedroomLaundry(),
            dustingVacuuming(),
            quickEntryway()
        ]
    }
    
    static func getAllDeepCleanTasks() -> [CleaningTask] {
        return [
            deepCleanKitchen(),
            deepCleanBathroom(),
            deepCleanLivingAreas(),
            deepCleanBedrooms()
        ]
    }
    
    // MARK: - Customize Task Duration
    
    static func adjustTaskDuration(_ task: CleaningTask, to duration: Int) -> CleaningTask {
        var adjusted = task
        adjusted.estimatedDuration = duration
        return adjusted
    }
}
