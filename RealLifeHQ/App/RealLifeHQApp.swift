import SwiftUI

// MARK: - Main App Entry Point
// This is where your iOS app starts running

@main
struct RealLifeHQApp: App {
    // StateObject keeps your data alive for the entire app
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)  // Makes theme available everywhere
                .environmentObject(dataManager)   // Makes data available everywhere
                .task {
                    // Request notification permissions when app launches
                    _ = await NotificationManager.shared.requestAuthorization()
                }
        }
    }
}
