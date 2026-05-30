import SwiftUI

// MARK: - Cleaning Setup Wizard
// Step-by-step setup for cleaning tracker
// Steps: 1) Rooms  2) Time & Days  3) Reminders (premium)  4) Review

struct CleaningSetupWizard: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager

    @State private var currentStep = 0
    @State private var profile = CleaningProfile()

    let totalSteps = 4

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar

                TabView(selection: $currentStep) {
                    // Step 1: Rooms
                    Step3FocusAreas(profile: $profile)
                        .tag(0)

                    // Step 2: Time & Days
                    Step2Preferences(profile: $profile)
                        .tag(1)

                    // Step 3: Reminders (premium-gated)
                    Step4Notifications(profile: $profile)
                        .tag(2)

                    // Step 4: Review
                    Step5Review(profile: $profile, onComplete: completeSetup)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                navigationButtons
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    Rectangle()
                        .fill(step <= currentStep
                              ? themeManager.currentTheme.primaryColor
                              : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }
            .padding(.horizontal)

            Text("Step \(currentStep + 1) of \(totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .background(themeManager.currentTheme.cardColor)
    }

    private var stepTitle: String {
        switch currentStep {
        case 0: return "Your Rooms"
        case 1: return "Schedule"
        case 2: return "Reminders"
        case 3: return "Review"
        default: return "Cleaning Setup"
        }
    }

    // MARK: - Navigation Buttons

    @ViewBuilder
    private var navigationButtons: some View {
        if currentStep < totalSteps - 1 {
            HStack(spacing: 12) {
                if currentStep > 0 {
                    Button {
                        withAnimation { currentStep -= 1 }
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor.opacity(0.15))
                        .cornerRadius(12)
                    }
                }

                Button {
                    withAnimation { currentStep += 1 }
                } label: {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
        }
    }

    // MARK: - Complete Setup

    private func completeSetup() {
        dataManager.setupCleaningProfile(profile)
        dataManager.scheduleCleaningNotifications()
        dismiss()
    }
}

#Preview {
    CleaningSetupWizard()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
