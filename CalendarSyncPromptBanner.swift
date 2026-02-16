import SwiftUI

/// A subtle banner that appears in CalendarView suggesting users enable calendar sync
struct CalendarSyncPromptBanner: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject private var calendarManager = AppleCalendarManager.shared
    @State private var isDismissed = false
    
    var body: some View {
        if !calendarManager.syncEnabled && !isDismissed {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sync with Apple Calendar")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text("Keep your events in sync automatically")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                NavigationLink(destination: CalendarSyncSettingsView()) {
                    Text("Enable")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(themeManager.currentTheme.primaryColor)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                
                Button {
                    withAnimation {
                        isDismissed = true
                        UserDefaults.standard.set(true, forKey: "calendarSyncPromptDismissed")
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(6)
                }
            }
            .padding()
            .background(themeManager.currentTheme.cardColor)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
            .padding(.top, 8)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    NavigationStack {
        VStack {
            CalendarSyncPromptBanner()
            Spacer()
        }
        .environmentObject(ThemeManager())
    }
}
