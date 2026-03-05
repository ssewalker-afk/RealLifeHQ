import SwiftUI

// MARK: - Cleaning Setup Wizard
// Step-by-step setup for cleaning tracker

struct CleaningSetupWizard: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    
    @State private var currentStep = 0
    @State private var profile = CleaningProfile()
    
    let totalSteps = 5
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                progressBar
                
                // Current Step Content
                TabView(selection: $currentStep) {
                    Step1HomeProfile(profile: $profile)
                        .tag(0)
                    
                    Step2Preferences(profile: $profile)
                        .tag(1)
                    
                    Step3FocusAreas(profile: $profile)
                        .tag(2)
                    
                    Step4Notifications(profile: $profile)
                        .tag(3)
                    
                    Step5Review(profile: $profile, onComplete: completeSetup)
                        .tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation Buttons
                navigationButtons
            }
            .navigationTitle("Cleaning Tracker Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
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
                        .fill(step <= currentStep ? themeManager.currentTheme.primaryColor : Color.gray.opacity(0.3))
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
    
    // MARK: - Navigation Buttons
    
    @ViewBuilder
    private var navigationButtons: some View {
        // Hide navigation buttons on the last step since Step5Review has its own button
        if currentStep < totalSteps - 1 {
            HStack(spacing: 12) {
                if currentStep > 0 {
                    Button {
                        withAnimation {
                            currentStep -= 1
                        }
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
                    withAnimation {
                        currentStep += 1
                    }
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

// MARK: - Step 1: Home Profile

struct Step1HomeProfile: View {
    @Binding var profile: CleaningProfile
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell us about your space")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("This helps us create a personalized cleaning schedule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Home Type
                VStack(alignment: .leading, spacing: 12) {
                    Text("Home Type")
                        .font(.headline)
                    
                    ForEach(CleaningProfile.HomeType.allCases, id: \.self) { type in
                        Button {
                            profile.homeType = type
                        } label: {
                            HStack {
                                Text(type.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if profile.homeType == type {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                }
                            }
                            .padding()
                            .background(
                                profile.homeType == type
                                ? themeManager.currentTheme.primaryColor.opacity(0.15)
                                : themeManager.currentTheme.cardColor
                            )
                            .cornerRadius(12)
                        }
                    }
                }
                
                // Bedrooms
                VStack(alignment: .leading, spacing: 12) {
                    Text("Number of Bedrooms")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { number in
                            Button {
                                profile.bedrooms = number
                            } label: {
                                Text("\(number)\(number == 5 ? "+" : "")")
                                    .font(.headline)
                                    .foregroundColor(profile.bedrooms == number ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        profile.bedrooms == number
                                        ? themeManager.currentTheme.primaryColor
                                        : themeManager.currentTheme.cardColor
                                    )
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Bathrooms
                VStack(alignment: .leading, spacing: 12) {
                    Text("Number of Bathrooms")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach(1...4, id: \.self) { number in
                            Button {
                                profile.bathrooms = number
                            } label: {
                                Text("\(number)\(number == 4 ? "+" : "")")
                                    .font(.headline)
                                    .foregroundColor(profile.bathrooms == number ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        profile.bathrooms == number
                                        ? themeManager.currentTheme.primaryColor
                                        : themeManager.currentTheme.cardColor
                                    )
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Pets
                VStack(alignment: .leading, spacing: 12) {
                    Text("Do you have pets?")
                        .font(.headline)
                    
                    Toggle("I have pets", isOn: $profile.hasPets)
                        .tint(themeManager.currentTheme.primaryColor)
                    
                    if profile.hasPets {
                        TextField("Type (e.g., 2 cats, 1 dog)", text: Binding(
                            get: { profile.petTypes ?? "" },
                            set: { profile.petTypes = $0 }
                        ))
                        .textFieldStyle(.roundedBorder)
                    }
                }
                
                // Household Size
                VStack(alignment: .leading, spacing: 12) {
                    Text("Household Size")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        ForEach([1, 2, 3, 4, 5], id: \.self) { size in
                            Button {
                                profile.householdSize = size
                            } label: {
                                Text(size == 5 ? "5+" : "\(size)")
                                    .font(.headline)
                                    .foregroundColor(profile.householdSize == size ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        profile.householdSize == size
                                        ? themeManager.currentTheme.primaryColor
                                        : themeManager.currentTheme.cardColor
                                    )
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    CleaningSetupWizard()
        .environmentObject(ThemeManager())
        .environmentObject(DataManager())
}
