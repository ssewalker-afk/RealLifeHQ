import SwiftUI

// MARK: - Launch Screen View
// Simple, static launch screen for the app

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background color - clean white or system background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Your custom logo from Assets
                Image("LaunchImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .cornerRadius(40)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                
                // App Name (optional - remove if your logo includes text)
                Text("RealLifeHQ")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.primary)
                
                // Tagline (optional)
                Text("Organize Your Life")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
