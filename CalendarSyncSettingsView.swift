import SwiftUI

/// Settings view for Apple Calendar integration
struct CalendarSyncSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject private var calendarManager = AppleCalendarManager.shared
    
    @State private var showingPermissionAlert = false
    @State private var showingImportSheet = false
    @State private var showingSyncConfirmation = false
    @State private var importStartDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var importEndDate = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        Form {
            // Authorization Status Section
            Section {
                HStack {
                    Image(systemName: calendarManager.isAuthorized ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(calendarManager.isAuthorized ? .green : .red)
                    
                    Text(calendarManager.isAuthorized ? "Access Granted" : "Access Required")
                        .font(.headline)
                }
                
                if !calendarManager.isAuthorized {
                    Button {
                        Task {
                            let granted = await calendarManager.requestAccess()
                            if !granted {
                                showingPermissionAlert = true
                            }
                        }
                    } label: {
                        Label("Grant Calendar Access", systemImage: "calendar.badge.plus")
                    }
                }
            } header: {
                Text("Calendar Permissions")
            } footer: {
                Text("Allow RealLifeHQ to read and write events to your Apple Calendar")
            }
            
            // Sync Settings Section
            Section {
                Toggle(isOn: Binding(
                    get: { calendarManager.syncEnabled },
                    set: { newValue in
                        if newValue && !calendarManager.isAuthorized {
                            showingPermissionAlert = true
                        } else {
                            calendarManager.setSyncEnabled(newValue)
                            if newValue {
                                showingSyncConfirmation = true
                            }
                        }
                    }
                )) {
                    Label("Sync with Apple Calendar", systemImage: "arrow.triangle.2.circlepath")
                }
                .disabled(!calendarManager.isAuthorized)
            } header: {
                Text("Sync Settings")
            } footer: {
                if calendarManager.syncEnabled {
                    Text("Events you create in RealLifeHQ will automatically be added to your Apple Calendar")
                } else {
                    Text("Enable to automatically sync your events to Apple Calendar")
                }
            }
            
            // Import Section
            if calendarManager.isAuthorized {
                Section {
                    Button {
                        showingImportSheet = true
                    } label: {
                        Label("Import Events from Apple Calendar", systemImage: "square.and.arrow.down")
                    }
                } header: {
                    Text("Import Events")
                } footer: {
                    Text("Import existing events from your Apple Calendar into RealLifeHQ")
                }
            }
            
            // Information Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(
                        icon: "checkmark.circle.fill",
                        title: "Two-way Sync",
                        description: "Changes in RealLifeHQ sync to Apple Calendar"
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
                        title: "Privacy First",
                        description: "Your calendar data stays on your device"
                    )
                }
            } header: {
                Text("How It Works")
            }
        }
        .navigationTitle("Calendar Sync")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Calendar Access Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enable calendar access in Settings to use this feature")
        }
        .alert("Sync Enabled", isPresented: $showingSyncConfirmation) {
            Button("Sync All Events Now") {
                syncAllEvents()
            }
            Button("Sync New Events Only", role: .cancel) { }
        } message: {
            Text("Would you like to sync all existing events to Apple Calendar now?")
        }
        .sheet(isPresented: $showingImportSheet) {
            NavigationStack {
                ImportEventsView(
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
    
    private func syncAllEvents() {
        Task {
            try? await calendarManager.syncAllEventsToAppleCalendar(dataManager.events)
        }
    }
    
    private func importEvents(from start: Date, to end: Date) {
        let importedEvents = calendarManager.importEvents(from: start, to: end)
        
        // Add imported events to DataManager (avoiding duplicates)
        for event in importedEvents {
            // Check if event already exists based on title and date
            let isDuplicate = dataManager.events.contains { existing in
                existing.title == event.title &&
                Calendar.current.isDate(existing.date, inSameDayAs: event.date)
            }
            
            if !isDuplicate {
                dataManager.addEvent(event)
            }
        }
    }
}

// MARK: - Import Events Sheet

struct ImportEventsView: View {
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
                Text("Events within this date range will be imported from your Apple Calendar")
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

// MARK: - Info Row Component

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CalendarSyncSettingsView()
            .environmentObject(ThemeManager())
            .environmentObject(DataManager())
    }
}
