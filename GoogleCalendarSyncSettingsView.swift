import SwiftUI

/// Settings view for Google Calendar integration
struct GoogleCalendarSyncSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject private var googleManager = GoogleCalendarManager.shared
    
    @State private var showingSignOutAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingImportSheet = false
    @State private var importStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var importEndDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var isAuthenticating = false
    
    var body: some View {
        Form {
            // Authentication Status Section
            Section {
                HStack {
                    Image(systemName: googleManager.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(googleManager.isAuthenticated ? .green : .red)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(googleManager.isAuthenticated ? "Connected" : "Not Connected")
                            .font(.headline)
                        
                        if let email = googleManager.userEmail {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if googleManager.isAuthenticated {
                        Button("Sign Out") {
                            showingSignOutAlert = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.red)
                    }
                }
                
                if !googleManager.isAuthenticated {
                    Button {
                        authenticateWithGoogle()
                    } label: {
                        HStack {
                            if isAuthenticating {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Image(systemName: "g.circle.fill")
                                Text("Sign in with Google")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isAuthenticating)
                }
            } header: {
                Text("Google Account")
            } footer: {
                if !googleManager.isAuthenticated {
                    Text("Sign in with your Google account to sync events with Google Calendar")
                }
            }
            
            // Sync Settings Section
            if googleManager.isAuthenticated {
                Section {
                    Toggle(isOn: Binding(
                        get: { googleManager.syncEnabled },
                        set: { googleManager.setSyncEnabled($0) }
                    )) {
                        Label("Sync with Google Calendar", systemImage: "arrow.triangle.2.circlepath")
                    }
                } header: {
                    Text("Sync Settings")
                } footer: {
                    if googleManager.syncEnabled {
                        Text("Events you create in RealLifeHQ will automatically be added to your Google Calendar")
                    } else {
                        Text("Enable to automatically sync your events to Google Calendar")
                    }
                }
                
                // Import Section
                Section {
                    Button {
                        showingImportSheet = true
                    } label: {
                        Label("Import Events from Google Calendar", systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("Import Events")
                } footer: {
                    Text("Import existing events from your Google Calendar into RealLifeHQ")
                }
            }
            
            // Setup Instructions Section
            if !googleManager.isAuthenticated {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How to Set Up")
                            .font(.headline)
                        
                        Text("1. Tap 'Sign in with Google'")
                        Text("2. Sign in to your Google account")
                        Text("3. Grant calendar access permissions")
                        Text("4. Enable sync to start syncing events")
                        
                        Divider()
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            
                            Text("Your Google Calendar credentials are securely stored on your device and never shared.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("Getting Started")
                }
            }
            
            // Information Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(
                        icon: "checkmark.circle.fill",
                        title: "Two-way Sync",
                        description: "Changes in RealLifeHQ sync to Google Calendar"
                    )
                    
                    Divider()
                    
                    InfoRow(
                        icon: "clock.fill",
                        title: "Real-time Updates",
                        description: "Events are synced immediately when created or modified"
                    )
                    
                    Divider()
                    
                    InfoRow(
                        icon: "lock.fill",
                        title: "Secure Authentication",
                        description: "OAuth 2.0 authentication via Google"
                    )
                    
                    Divider()
                    
                    InfoRow(
                        icon: "arrow.clockwise",
                        title: "Access Anytime",
                        description: "View your events in Google Calendar, Gmail, and more"
                    )
                }
            } header: {
                Text("How It Works")
            }
        }
        .navigationTitle("Google Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Sign Out", role: .destructive) {
                googleManager.signOut()
            }
        } message: {
            Text("Are you sure you want to sign out of Google Calendar? Your events will remain in Google Calendar, but new events won't sync until you sign in again.")
        }
        .alert("Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showingImportSheet) {
            NavigationStack {
                ImportGoogleEventsView(
                    startDate: $importStartDate,
                    endDate: $importEndDate,
                    onImport: { start, end in
                        importEvents(from: start, to: end)
                        showingImportSheet = false
                    }
                )
            }
        }
    }
    
    private func authenticateWithGoogle() {
        isAuthenticating = true
        Task {
            do {
                try await googleManager.authenticate()
            } catch {
                errorMessage = error.localizedDescription
                showingErrorAlert = true
            }
            isAuthenticating = false
        }
    }
    
    private func importEvents(from start: Date, to end: Date) {
        Task {
            do {
                let googleEvents = try await googleManager.fetchEvents(from: start, to: end)
                
                await MainActor.run {
                    for googleEvent in googleEvents {
                        let event = googleManager.convertToAppEvent(googleEvent)
                        
                        // Check if event already exists
                        let isDuplicate = dataManager.events.contains { existing in
                            existing.title == event.title &&
                            Calendar.current.isDate(existing.date, inSameDayAs: event.date)
                        }
                        
                        if !isDuplicate {
                            dataManager.addEvent(event)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to import events: \(error.localizedDescription)"
                    showingErrorAlert = true
                }
            }
        }
    }
}

// MARK: - Import Events Sheet

struct ImportGoogleEventsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    @Binding var startDate: Date
    @Binding var endDate: Date
    let onImport: (Date, Date) -> Void
    
    var body: some View {
        Form {
            Section {
                DatePicker("From", selection: $startDate, displayedComponents: .date)
                DatePicker("To", selection: $endDate, displayedComponents: .date)
            } header: {
                Text("Select Date Range")
            } footer: {
                Text("Events within this date range will be imported from your Google Calendar")
            }
            
            Section {
                Button {
                    onImport(startDate, endDate)
                } label: {
                    HStack {
                        Spacer()
                        Text("Import Events")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(startDate > endDate)
            }
        }
        .navigationTitle("Import Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        GoogleCalendarSyncSettingsView()
            .environmentObject(ThemeManager())
            .environmentObject(DataManager())
    }
}
