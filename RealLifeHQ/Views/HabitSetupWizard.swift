import SwiftUI

// MARK: - Local Models (wizard-only)

private struct HabitCategoryModel {
    let name: String
    let icon: String
    let color: String
    let habits: [HabitSuggestion]
}

private struct HabitSuggestion: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
    let why: String
}

private struct CustomHabitDraft: Identifiable {
    var id = UUID()
    var name: String
    var icon: String = "star.fill"
    var color: String = "blue"
}

// MARK: - Habit Setup Wizard

struct HabitSetupWizard: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("habitWizardCompleted") private var habitWizardCompleted = false

    @State private var currentPage = 0
    @State private var selectedCategories: Set<String> = []
    @State private var selectedHabitIDs: Set<UUID> = []
    @State private var customHabits: [CustomHabitDraft] = []
    @State private var newCustomName = ""
    @State private var newCustomIcon = "star.fill"
    @State private var newCustomColor = "blue"

    private let totalPages = 3

    private let categories: [HabitCategoryModel] = [
        HabitCategoryModel(name: "Health & Fitness", icon: "figure.run", color: "green", habits: [
            HabitSuggestion(name: "Daily Walk",        icon: "figure.walk",                         color: "green",  why: "Walking daily boosts energy and reduces stress."),
            HabitSuggestion(name: "Drink Water",       icon: "drop.fill",                           color: "blue",   why: "Staying hydrated improves focus and mood."),
            HabitSuggestion(name: "Morning Stretch",   icon: "figure.flexibility",                  color: "green",  why: "Stretching reduces tension and improves posture."),
            HabitSuggestion(name: "Work Out",          icon: "figure.strengthtraining.traditional", color: "orange", why: "Regular exercise builds strength and resilience."),
            HabitSuggestion(name: "Early Bedtime",     icon: "moon.fill",                           color: "purple", why: "Quality sleep is the foundation of every habit."),
        ]),
        HabitCategoryModel(name: "Mental Wellness", icon: "brain.head.profile", color: "purple", habits: [
            HabitSuggestion(name: "Meditate",            icon: "brain.head.profile", color: "purple", why: "Even 5 minutes of mindfulness reduces anxiety."),
            HabitSuggestion(name: "Daily Journal",       icon: "book.fill",          color: "purple", why: "Journaling helps you process thoughts and emotions."),
            HabitSuggestion(name: "Gratitude List",      icon: "heart.fill",         color: "pink",   why: "Three daily gratitudes rewire your brain for positivity."),
            HabitSuggestion(name: "Breathing Exercises", icon: "wind",               color: "teal",   why: "Deep breathing activates your body's calm response."),
        ]),
        HabitCategoryModel(name: "Self-Care", icon: "sparkles", color: "pink", habits: [
            HabitSuggestion(name: "Skincare Routine",     icon: "sparkles",           color: "pink",   why: "A consistent routine builds a calming daily anchor."),
            HabitSuggestion(name: "No Screens Before Bed",icon: "moon.zzz.fill",      color: "purple", why: "Cutting screens improves your sleep quality naturally."),
            HabitSuggestion(name: "Leisure Reading",      icon: "books.vertical.fill",color: "orange", why: "Reading before bed is one of the best wind-down habits."),
            HabitSuggestion(name: "Enjoy a Hobby",        icon: "paintbrush.fill",    color: "pink",   why: "Time for creativity refuels motivation and joy."),
        ]),
        HabitCategoryModel(name: "Productivity", icon: "checklist", color: "blue", habits: [
            HabitSuggestion(name: "Plan Tomorrow Tonight", icon: "checklist",       color: "blue",   why: "5 minutes of planning saves hours of confusion."),
            HabitSuggestion(name: "Morning Routine",       icon: "sunrise.fill",    color: "orange", why: "A structured morning sets the tone for your day."),
            HabitSuggestion(name: "No Phone First 30 Min", icon: "iphone.slash",    color: "teal",   why: "Protecting your morning protects your focus."),
            HabitSuggestion(name: "Weekly Review",         icon: "arrow.clockwise", color: "blue",   why: "A weekly check-in keeps your goals on track."),
        ]),
        HabitCategoryModel(name: "Learning & Growth", icon: "book.open.fill", color: "orange", habits: [
            HabitSuggestion(name: "Read Daily",          icon: "book.open.fill", color: "orange", why: "15 minutes a day compounds into real knowledge."),
            HabitSuggestion(name: "Practice a Skill",    icon: "pencil",         color: "blue",   why: "Deliberate daily practice creates real expertise."),
            HabitSuggestion(name: "Listen to a Podcast", icon: "headphones",     color: "purple", why: "Learning during commutes multiplies your time."),
        ]),
        HabitCategoryModel(name: "Home & Organization", icon: "house.fill", color: "teal", habits: [
            HabitSuggestion(name: "Make Your Bed", icon: "bed.double.fill", color: "teal", why: "A made bed triggers a sense of order all day."),
            HabitSuggestion(name: "5-Min Tidy",    icon: "house.fill",      color: "teal", why: "A quick daily tidy prevents bigger weekend cleanups."),
            HabitSuggestion(name: "Do the Dishes", icon: "sink.fill",       color: "blue", why: "A clean kitchen acts as a reset button for your home."),
        ]),
        HabitCategoryModel(name: "Finance", icon: "dollarsign.circle.fill", color: "green", habits: [
            HabitSuggestion(name: "Log Daily Spending",   icon: "dollarsign.circle.fill", color: "green",  why: "Awareness is the first step to financial health."),
            HabitSuggestion(name: "No Impulse Buys",      icon: "cart.badge.minus",       color: "orange", why: "A 24-hour pause prevents regret purchases."),
            HabitSuggestion(name: "Review Budget Weekly", icon: "chart.bar.fill",          color: "green",  why: "Regular check-ins keep your financial goals on track."),
        ]),
        HabitCategoryModel(name: "Social & Relationships", icon: "person.2.fill", color: "blue", habits: [
            HabitSuggestion(name: "Connect with Someone",    icon: "person.2.fill",       color: "blue",   why: "Daily human connection is vital for wellbeing."),
            HabitSuggestion(name: "Call a Family Member",    icon: "phone.fill",          color: "green",  why: "Regular calls strengthen your most important bonds."),
            HabitSuggestion(name: "Random Act of Kindness",  icon: "hand.thumbsup.fill",  color: "orange", why: "Small acts of kindness boost your own happiness too."),
        ]),
    ]

    private var suggestionsForSelected: [HabitCategoryModel] {
        categories.filter { selectedCategories.contains($0.name) }
    }

    private var totalSelectedCount: Int {
        selectedHabitIDs.count + customHabits.count
    }

    private var canAdvance: Bool {
        currentPage == 0 ? !selectedCategories.isEmpty : true
    }

    var body: some View {
        VStack(spacing: 0) {
            wizardHeader
            Group {
                switch currentPage {
                case 0: categorySelectionPage
                case 1: habitPickingPage
                default: reviewPage
                }
            }
            .animation(.easeInOut(duration: 0.2), value: currentPage)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            wizardNavigation
        }
        .background(themeManager.currentTheme.backgroundColor.ignoresSafeArea())
    }

    // MARK: - Header

    private var wizardHeader: some View {
        HStack {
            Button("Skip") { completeWizard(skipped: true) }
                .foregroundColor(.secondary)
                .font(.subheadline)

            Spacer()

            HStack(spacing: 6) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Circle()
                        .fill(i <= currentPage
                              ? themeManager.currentTheme.primaryColor
                              : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }

            Spacer()

            Text("Step \(currentPage + 1) of \(totalPages)")
                .foregroundColor(.secondary)
                .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
    }

    // MARK: - Navigation

    private var wizardNavigation: some View {
        HStack {
            if currentPage > 0 {
                Button("Back") { withAnimation { currentPage -= 1 } }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            Spacer()
            if currentPage < totalPages - 1 {
                Button("Next") { withAnimation { currentPage += 1 } }
                    .disabled(!canAdvance)
                    .padding(.horizontal, 24).padding(.vertical, 10)
                    .background(canAdvance ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            } else {
                Button("Start Building Habits") { completeWizard(skipped: false) }
                    .disabled(totalSelectedCount == 0)
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(totalSelectedCount > 0 ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    // MARK: - Page 1: Category Selection

    private var categorySelectionPage: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "target")
                        .font(.system(size: 56))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("What do you want to improve?")
                        .font(.title2).fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Text("Select all the areas you'd like to build habits in.")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(categories, id: \.name) { category in
                        HabitCategoryTile(
                            name: category.name,
                            icon: category.icon,
                            color: category.color,
                            isSelected: selectedCategories.contains(category.name)
                        ) {
                            if selectedCategories.contains(category.name) {
                                selectedCategories.remove(category.name)
                            } else {
                                selectedCategories.insert(category.name)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Page 2: Habit Picking

    private var habitPickingPage: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Text("Pick Your Habits")
                        .font(.title2).fontWeight(.bold)
                    Text("Tap to select. Starting with 2–3 habits builds the strongest streaks.")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Curated suggestions grouped by category
                ForEach(suggestionsForSelected, id: \.name) { category in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .foregroundColor(colorFromString(category.color))
                            Text(category.name)
                                .font(.headline)
                                .foregroundColor(colorFromString(category.color))
                        }
                        ForEach(category.habits) { habit in
                            HabitSuggestionCard(
                                name: habit.name,
                                icon: habit.icon,
                                color: habit.color,
                                why: habit.why,
                                isSelected: selectedHabitIDs.contains(habit.id),
                                primaryColor: themeManager.currentTheme.primaryColor
                            ) {
                                if selectedHabitIDs.contains(habit.id) {
                                    selectedHabitIDs.remove(habit.id)
                                } else {
                                    selectedHabitIDs.insert(habit.id)
                                }
                            }
                        }
                    }
                }

                // Custom habit section
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(themeManager.currentTheme.accentColor)
                        Text("Add a Custom Habit")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.accentColor)
                    }

                    // Already-added custom habits
                    if !customHabits.isEmpty {
                        VStack(spacing: 6) {
                            ForEach(customHabits) { habit in
                                HStack(spacing: 10) {
                                    Image(systemName: habit.icon)
                                        .foregroundColor(colorFromString(habit.color))
                                        .frame(width: 28)
                                    Text(habit.name).font(.subheadline)
                                    Spacer()
                                    Button {
                                        customHabits.removeAll { $0.id == habit.id }
                                    } label: {
                                        Image(systemName: "minus.circle.fill").foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal, 12).padding(.vertical, 8)
                                .background(themeManager.currentTheme.cardColor)
                                .cornerRadius(8)
                            }
                        }
                    }

                    // New custom habit input
                    VStack(spacing: 12) {
                        TextField("Habit name (e.g. Walk the dog)", text: $newCustomName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        let iconOptions = ["star.fill","flame.fill","bolt.fill","leaf.fill","figure.walk","dumbbell.fill","pencil","music.note","cup.and.saucer.fill","clock.fill","heart.fill","sun.max.fill"]
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    Image(systemName: icon).font(.title3)
                                        .frame(width: 42, height: 42)
                                        .foregroundColor(newCustomIcon == icon ? .white : .primary)
                                        .background(newCustomIcon == icon ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.15))
                                        .cornerRadius(8)
                                        .onTapGesture { newCustomIcon = icon }
                                }
                            }
                            .padding(.horizontal, 2)
                        }

                        let colorOptions = ["blue","green","purple","orange","pink","teal","red"]
                        HStack(spacing: 8) {
                            ForEach(colorOptions, id: \.self) { c in
                                Circle().fill(colorFromString(c))
                                    .frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.white, lineWidth: newCustomColor == c ? 3 : 0).padding(2))
                                    .overlay(Circle().stroke(colorFromString(c).opacity(0.6), lineWidth: newCustomColor == c ? 2 : 0))
                                    .onTapGesture { newCustomColor = c }
                            }
                            Spacer()
                            Button("Add") {
                                let trimmed = newCustomName.trimmingCharacters(in: .whitespaces)
                                guard !trimmed.isEmpty else { return }
                                customHabits.append(CustomHabitDraft(name: trimmed, icon: newCustomIcon, color: newCustomColor))
                                newCustomName = ""
                            }
                            .disabled(newCustomName.trimmingCharacters(in: .whitespaces).isEmpty)
                            .padding(.horizontal, 18).padding(.vertical, 8)
                            .background(newCustomName.trimmingCharacters(in: .whitespaces).isEmpty
                                        ? Color.gray.opacity(0.3) : themeManager.currentTheme.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(themeManager.currentTheme.cardColor)
                    .cornerRadius(12)
                }
            }
            .padding()
        }
    }

    // MARK: - Page 3: Review

    private var reviewPage: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: totalSelectedCount > 0 ? "checkmark.seal.fill" : "questionmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(themeManager.currentTheme.primaryColor)

                Text("Ready to Build?")
                    .font(.title2).fontWeight(.bold)

                if totalSelectedCount == 0 {
                    Text("You haven't selected any habits yet. Go back and pick some, or add a custom one.")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("You're adding \(totalSelectedCount) habit\(totalSelectedCount == 1 ? "" : "s"). All set to daily frequency — you can adjust any habit later.")
                        .font(.subheadline).foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    if totalSelectedCount > 3 {
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lightbulb.fill").foregroundColor(.orange).padding(.top, 1)
                            Text("Research shows starting with 2–3 habits leads to better long-term streaks. Consider trimming your list — you can always add more later.")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // List of all selected habits
                    let allSuggestions = suggestionsForSelected.flatMap { $0.habits }
                    let picked = allSuggestions.filter { selectedHabitIDs.contains($0.id) }

                    VStack(spacing: 6) {
                        ForEach(picked) { habit in
                            HStack(spacing: 10) {
                                Image(systemName: habit.icon)
                                    .foregroundColor(colorFromString(habit.color))
                                    .frame(width: 24)
                                Text(habit.name).font(.subheadline)
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                    .font(.subheadline)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(themeManager.currentTheme.cardColor)
                            .cornerRadius(8)
                        }
                        ForEach(customHabits) { habit in
                            HStack(spacing: 10) {
                                Image(systemName: habit.icon)
                                    .foregroundColor(colorFromString(habit.color))
                                    .frame(width: 24)
                                Text(habit.name).font(.subheadline)
                                Text("Custom")
                                    .font(.caption2).foregroundColor(.secondary)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Color.gray.opacity(0.12))
                                    .cornerRadius(4)
                                Spacer()
                            }
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .background(themeManager.currentTheme.cardColor)
                            .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Helpers

    private func colorFromString(_ string: String) -> Color {
        switch string.lowercased() {
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "red":    return .red
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return .blue
        }
    }

    // MARK: - Completion

    private func completeWizard(skipped: Bool) {
        if !skipped {
            let allSuggestions = categories.flatMap { $0.habits }
            for suggestion in allSuggestions where selectedHabitIDs.contains(suggestion.id) {
                dataManager.addHabit(Habit(
                    name: suggestion.name,
                    icon: suggestion.icon,
                    color: suggestion.color,
                    frequency: .daily,
                    selectedDays: Set([1, 2, 3, 4, 5, 6, 7]),
                    reminderEnabled: false,
                    reminderTime: nil
                ))
            }
            for draft in customHabits {
                dataManager.addHabit(Habit(
                    name: draft.name,
                    icon: draft.icon,
                    color: draft.color,
                    frequency: .daily,
                    selectedDays: Set([1, 2, 3, 4, 5, 6, 7]),
                    reminderEnabled: false,
                    reminderTime: nil
                ))
            }
        }
        habitWizardCompleted = true
        dismiss()
    }
}

// MARK: - Category Tile

private struct HabitCategoryTile: View {
    let name: String
    let icon: String
    let color: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(resolvedColor.opacity(isSelected ? 0.2 : 0.1))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(resolvedColor)
                }
                Text(name)
                    .font(.caption).fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? resolvedColor.opacity(0.1) : Color(.systemBackground).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? resolvedColor : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var resolvedColor: Color {
        switch color {
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return .blue
        }
    }
}

// MARK: - Habit Suggestion Card

private struct HabitSuggestionCard: View {
    let name: String
    let icon: String
    let color: String
    let why: String
    let isSelected: Bool
    let primaryColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(resolvedColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon).foregroundColor(resolvedColor)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(name).font(.subheadline).fontWeight(.medium).foregroundColor(.primary)
                    Text(why).font(.caption).foregroundColor(.secondary).lineLimit(2)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? primaryColor : Color.gray.opacity(0.4))
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? primaryColor.opacity(0.07) : Color(.systemBackground).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isSelected ? primaryColor : Color.gray.opacity(0.15), lineWidth: isSelected ? 1.5 : 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var resolvedColor: Color {
        switch color {
        case "blue":   return .blue
        case "purple": return .purple
        case "green":  return .green
        case "orange": return .orange
        case "pink":   return .pink
        case "teal":   return .teal
        default:       return .blue
        }
    }
}
