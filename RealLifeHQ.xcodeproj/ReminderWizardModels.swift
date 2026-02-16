import Foundation

// MARK: - Reminder Wizard Models

/// Life situation categories that determine which reminders to show
enum LifeSituation: String, CaseIterable, Identifiable {
    case hasCar = "Do you have a car?"
    case hasPets = "Do you have pets?"
    case ownsHome = "Do you own a home?"
    case rentsHome = "Do you rent a home?"
    case isStudent = "Are you a student?"
    case isSelfEmployed = "Are you self-employed?"
    case hasChildren = "Do you have children?"
    case wearsContacts = "Do you wear contact lenses?"
    case hasGarden = "Do you have a garden/lawn?"
    case hasPoolOrSpa = "Do you have a pool or spa?"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .hasCar: return "car.fill"
        case .hasPets: return "pawprint.fill"
        case .ownsHome: return "house.fill"
        case .rentsHome: return "building.2.fill"
        case .isStudent: return "graduationcap.fill"
        case .isSelfEmployed: return "briefcase.fill"
        case .hasChildren: return "figure.2.and.child.holdinghands"
        case .wearsContacts: return "eye.fill"
        case .hasGarden: return "leaf.fill"
        case .hasPoolOrSpa: return "drop.fill"
        }
    }
}

/// Frequency options for recurring reminders
enum ReminderFrequency: String, CaseIterable {
    case monthly = "Monthly"
    case quarterly = "Every 3 months"
    case biannually = "Every 6 months"
    case annually = "Yearly"
    case biennial = "Every 2 years"
    
    var recurrenceRule: Event.RecurrenceRule {
        switch self {
        case .monthly: return .monthly
        case .quarterly: return .monthly // Will need custom handling
        case .biannually: return .monthly // Will need custom handling
        case .annually: return .yearly
        case .biennial: return .yearly // Will need custom handling
        }
    }
    
    var monthsInterval: Int {
        switch self {
        case .monthly: return 1
        case .quarterly: return 3
        case .biannually: return 6
        case .annually: return 12
        case .biennial: return 24
        }
    }
}

/// Template for a suggested reminder
struct ReminderTemplate: Identifiable {
    let id = UUID()
    let title: String
    let category: LifeSituation?  // nil means universal reminder
    let suggestedFrequency: ReminderFrequency
    let description: String
    let icon: String
    
    init(title: String, category: LifeSituation? = nil, frequency: ReminderFrequency, description: String, icon: String) {
        self.title = title
        self.category = category
        self.suggestedFrequency = frequency
        self.description = description
        self.icon = icon
    }
}

// MARK: - Reminder Templates Database

struct ReminderTemplatesDatabase {
    
    /// Get all reminder templates for selected life situations
    static func getTemplates(for situations: Set<LifeSituation>) -> [ReminderTemplate] {
        var templates: [ReminderTemplate] = []
        
        // Universal reminders (everyone should see)
        templates.append(contentsOf: universalReminders)
        
        // Category-specific reminders
        if situations.contains(.hasCar) {
            templates.append(contentsOf: carReminders)
        }
        
        if situations.contains(.hasPets) {
            templates.append(contentsOf: petReminders)
        }
        
        if situations.contains(.ownsHome) {
            templates.append(contentsOf: homeOwnerReminders)
        }
        
        if situations.contains(.rentsHome) {
            templates.append(contentsOf: renterReminders)
        }
        
        if situations.contains(.isStudent) {
            templates.append(contentsOf: studentReminders)
        }
        
        if situations.contains(.isSelfEmployed) {
            templates.append(contentsOf: selfEmployedReminders)
        }
        
        if situations.contains(.hasChildren) {
            templates.append(contentsOf: parentReminders)
        }
        
        if situations.contains(.wearsContacts) {
            templates.append(contentsOf: contactLensReminders)
        }
        
        if situations.contains(.hasGarden) {
            templates.append(contentsOf: gardenReminders)
        }
        
        if situations.contains(.hasPoolOrSpa) {
            templates.append(contentsOf: poolReminders)
        }
        
        return templates
    }
    
    // MARK: - Universal Reminders (Everyone)
    
    private static let universalReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Dental Cleaning",
            frequency: .biannually,
            description: "Schedule your routine dental checkup and cleaning",
            icon: "cross.case.fill"
        ),
        ReminderTemplate(
            title: "Annual Physical Exam",
            frequency: .annually,
            description: "Book your yearly health checkup with your doctor",
            icon: "heart.text.square.fill"
        ),
        ReminderTemplate(
            title: "Eye Exam",
            frequency: .annually,
            description: "Get your vision checked and prescription updated",
            icon: "eye.fill"
        ),
        ReminderTemplate(
            title: "File Taxes",
            frequency: .annually,
            description: "Prepare and file your annual tax return",
            icon: "doc.text.fill"
        ),
        ReminderTemplate(
            title: "Review Insurance Coverage",
            frequency: .annually,
            description: "Review health, life, and other insurance policies",
            icon: "shield.fill"
        ),
        ReminderTemplate(
            title: "Change Smoke Detector Batteries",
            frequency: .biannually,
            description: "Replace batteries in all smoke detectors",
            icon: "smoke.fill"
        ),
        ReminderTemplate(
            title: "Backup Important Files",
            frequency: .monthly,
            description: "Create backups of important documents and photos",
            icon: "externaldrive.fill"
        )
    ]
    
    // MARK: - Car Owner Reminders
    
    private static let carReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Oil Change",
            category: .hasCar,
            frequency: .quarterly,
            description: "Change engine oil and filter",
            icon: "wrench.and.screwdriver.fill"
        ),
        ReminderTemplate(
            title: "Car Registration Renewal",
            category: .hasCar,
            frequency: .annually,
            description: "Renew vehicle registration and tags",
            icon: "doc.text.fill"
        ),
        ReminderTemplate(
            title: "Tire Rotation",
            category: .hasCar,
            frequency: .biannually,
            description: "Rotate tires for even wear",
            icon: "car.fill"
        ),
        ReminderTemplate(
            title: "Vehicle Inspection",
            category: .hasCar,
            frequency: .annually,
            description: "Complete required safety and emissions inspection",
            icon: "checkmark.shield.fill"
        ),
        ReminderTemplate(
            title: "Replace Air Filter",
            category: .hasCar,
            frequency: .annually,
            description: "Change engine and cabin air filters",
            icon: "wind"
        ),
        ReminderTemplate(
            title: "Car Insurance Review",
            category: .hasCar,
            frequency: .annually,
            description: "Review and update auto insurance coverage",
            icon: "shield.car.fill"
        )
    ]
    
    // MARK: - Pet Owner Reminders
    
    private static let petReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Vet Checkup",
            category: .hasPets,
            frequency: .annually,
            description: "Annual wellness exam for your pet",
            icon: "cross.case.fill"
        ),
        ReminderTemplate(
            title: "Pet Vaccinations",
            category: .hasPets,
            frequency: .annually,
            description: "Update required vaccinations",
            icon: "syringe.fill"
        ),
        ReminderTemplate(
            title: "Flea & Tick Prevention",
            category: .hasPets,
            frequency: .monthly,
            description: "Apply monthly flea and tick treatment",
            icon: "allergens.fill"
        ),
        ReminderTemplate(
            title: "Heartworm Prevention",
            category: .hasPets,
            frequency: .monthly,
            description: "Give monthly heartworm medication",
            icon: "heart.fill"
        ),
        ReminderTemplate(
            title: "Pet License Renewal",
            category: .hasPets,
            frequency: .annually,
            description: "Renew pet license with city/county",
            icon: "doc.badge.gearshape.fill"
        ),
        ReminderTemplate(
            title: "Grooming Appointment",
            category: .hasPets,
            frequency: .quarterly,
            description: "Schedule professional grooming",
            icon: "scissors"
        )
    ]
    
    // MARK: - Home Owner Reminders
    
    private static let homeOwnerReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "HVAC Filter Replacement",
            category: .ownsHome,
            frequency: .quarterly,
            description: "Replace heating/cooling system filters",
            icon: "wind"
        ),
        ReminderTemplate(
            title: "HVAC System Maintenance",
            category: .ownsHome,
            frequency: .biannually,
            description: "Professional HVAC system inspection and service",
            icon: "fan.fill"
        ),
        ReminderTemplate(
            title: "Gutter Cleaning",
            category: .ownsHome,
            frequency: .biannually,
            description: "Clean gutters and downspouts",
            icon: "house.fill"
        ),
        ReminderTemplate(
            title: "Property Tax Payment",
            category: .ownsHome,
            frequency: .annually,
            description: "Pay annual property taxes",
            icon: "dollarsign.circle.fill"
        ),
        ReminderTemplate(
            title: "Homeowners Insurance Review",
            category: .ownsHome,
            frequency: .annually,
            description: "Review and update home insurance policy",
            icon: "shield.fill"
        ),
        ReminderTemplate(
            title: "Water Heater Flush",
            category: .ownsHome,
            frequency: .annually,
            description: "Flush sediment from water heater",
            icon: "drop.fill"
        ),
        ReminderTemplate(
            title: "Chimney Inspection",
            category: .ownsHome,
            frequency: .annually,
            description: "Inspect and clean chimney if applicable",
            icon: "flame.fill"
        ),
        ReminderTemplate(
            title: "Septic Tank Pumping",
            category: .ownsHome,
            frequency: .quarterly,
            description: "Pump septic tank (if applicable)",
            icon: "arrow.down.circle.fill"
        )
    ]
    
    // MARK: - Renter Reminders
    
    private static let renterReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Renters Insurance Review",
            category: .rentsHome,
            frequency: .annually,
            description: "Review and update renters insurance policy",
            icon: "shield.fill"
        ),
        ReminderTemplate(
            title: "Lease Renewal Decision",
            category: .rentsHome,
            frequency: .annually,
            description: "Decide on lease renewal (60-90 days before expiration)",
            icon: "doc.text.fill"
        )
    ]
    
    // MARK: - Student Reminders
    
    private static let studentReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Course Registration",
            category: .isStudent,
            frequency: .biannually,
            description: "Register for next semester's classes",
            icon: "graduationcap.fill"
        ),
        ReminderTemplate(
            title: "FAFSA Submission",
            category: .isStudent,
            frequency: .annually,
            description: "Complete and submit FAFSA for financial aid",
            icon: "doc.fill"
        ),
        ReminderTemplate(
            title: "Scholarship Applications",
            category: .isStudent,
            frequency: .annually,
            description: "Research and apply for scholarships",
            icon: "star.fill"
        ),
        ReminderTemplate(
            title: "Academic Advisor Meeting",
            category: .isStudent,
            frequency: .biannually,
            description: "Schedule meeting with academic advisor",
            icon: "person.fill"
        )
    ]
    
    // MARK: - Self-Employed Reminders
    
    private static let selfEmployedReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Quarterly Tax Payments",
            category: .isSelfEmployed,
            frequency: .quarterly,
            description: "Pay estimated quarterly taxes (IRS Form 1040-ES)",
            icon: "dollarsign.circle.fill"
        ),
        ReminderTemplate(
            title: "Business License Renewal",
            category: .isSelfEmployed,
            frequency: .annually,
            description: "Renew business license and permits",
            icon: "doc.badge.gearshape.fill"
        ),
        ReminderTemplate(
            title: "Review Business Insurance",
            category: .isSelfEmployed,
            frequency: .annually,
            description: "Review liability and business insurance coverage",
            icon: "shield.fill"
        ),
        ReminderTemplate(
            title: "Expense Tracking Review",
            category: .isSelfEmployed,
            frequency: .monthly,
            description: "Review and categorize business expenses",
            icon: "chart.bar.fill"
        )
    ]
    
    // MARK: - Parent Reminders
    
    private static let parentReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Pediatrician Checkup",
            category: .hasChildren,
            frequency: .annually,
            description: "Schedule annual wellness visit for children",
            icon: "stethoscope"
        ),
        ReminderTemplate(
            title: "School Registration",
            category: .hasChildren,
            frequency: .annually,
            description: "Complete school registration and enrollment",
            icon: "building.columns.fill"
        ),
        ReminderTemplate(
            title: "Update Emergency Contacts",
            category: .hasChildren,
            frequency: .annually,
            description: "Update emergency contacts with school/daycare",
            icon: "phone.fill"
        ),
        ReminderTemplate(
            title: "Summer Camp Registration",
            category: .hasChildren,
            frequency: .annually,
            description: "Research and register for summer activities",
            icon: "figure.hiking"
        )
    ]
    
    // MARK: - Contact Lens Reminders
    
    private static let contactLensReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Replace Contact Lenses",
            category: .wearsContacts,
            frequency: .monthly,
            description: "Replace monthly contact lenses",
            icon: "eye.fill"
        ),
        ReminderTemplate(
            title: "Order Contact Lens Supply",
            category: .wearsContacts,
            frequency: .quarterly,
            description: "Reorder contact lens supply before running out",
            icon: "cart.fill"
        )
    ]
    
    // MARK: - Garden/Lawn Reminders
    
    private static let gardenReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Fertilize Lawn",
            category: .hasGarden,
            frequency: .quarterly,
            description: "Apply lawn fertilizer seasonally",
            icon: "leaf.fill"
        ),
        ReminderTemplate(
            title: "Aerate Lawn",
            category: .hasGarden,
            frequency: .annually,
            description: "Aerate lawn for healthy growth",
            icon: "circle.grid.cross.fill"
        ),
        ReminderTemplate(
            title: "Prune Trees/Shrubs",
            category: .hasGarden,
            frequency: .annually,
            description: "Prune trees and shrubs for health and shape",
            icon: "scissors"
        ),
        ReminderTemplate(
            title: "Mulch Garden Beds",
            category: .hasGarden,
            frequency: .annually,
            description: "Add fresh mulch to garden beds",
            icon: "square.stack.3d.up.fill"
        )
    ]
    
    // MARK: - Pool/Spa Reminders
    
    private static let poolReminders: [ReminderTemplate] = [
        ReminderTemplate(
            title: "Pool Opening/Closing",
            category: .hasPoolOrSpa,
            frequency: .biannually,
            description: "Open pool for summer or close for winter",
            icon: "drop.fill"
        ),
        ReminderTemplate(
            title: "Pool Equipment Maintenance",
            category: .hasPoolOrSpa,
            frequency: .annually,
            description: "Service pool pump, filter, and heater",
            icon: "wrench.and.screwdriver.fill"
        ),
        ReminderTemplate(
            title: "Pool Inspection",
            category: .hasPoolOrSpa,
            frequency: .annually,
            description: "Professional pool safety and equipment inspection",
            icon: "checkmark.shield.fill"
        )
    ]
}
