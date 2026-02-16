import SwiftUI

// MARK: - Main App Entry Point
// This is where your iOS app starts running

@main
struct RealLifeHQApp: App {
    // StateObject keeps your data alive for the entire app
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var dataManager = DataManager()
    @State private var showLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(themeManager)  // Makes theme available everywhere
                    .environmentObject(dataManager)   // Makes data available everywhere
                    .task {
                        // Request notification permissions when app launches
                        _ = await NotificationManager.shared.requestAuthorization()
                    }
                    .opacity(showLaunchScreen ? 0 : 1)  // Hide content while showing launch screen
                
                // Show launch screen overlay briefly
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(2)
                        .onAppear {
                            // Hide launch screen after brief delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showLaunchScreen = false
                                }
                            }
                        }
                }
            }
        }
    }
}
