import SwiftUI
import Combine

// MARK: - App Theme System
// This manages all colors and appearance for your app

class ThemeManager: ObservableObject {
    // @Published means the UI updates automatically when this changes
    @Published var currentTheme: AppTheme = .emeraldViolet
    
    // Available color themes (all gender-neutral, no browns!)
    enum AppTheme: String, CaseIterable, Identifiable {
        case tealAmber = "Teal & Amber"
        case purplePink = "Purple & Pink"
        case blueGreen = "Blue & Green"
        case emeraldViolet = "Emerald & Violet"
        
        var id: String { rawValue }
        
        // Primary color for each theme
        var primaryColor: Color {
            switch self {
            case .tealAmber: return Color(hex: "0d9488")      // Teal
            case .purplePink: return Color(hex: "a855f7")     // Purple
            case .blueGreen: return Color(hex: "3b82f6")      // Blue
            case .emeraldViolet: return Color(hex: "10b981")  // Emerald
            }
        }
        
        // Accent color for each theme
        var accentColor: Color {
            switch self {
            case .tealAmber: return Color(hex: "b45309")      // Amber
            case .purplePink: return Color(hex: "db2777")     // Pink
            case .blueGreen: return Color(hex: "16a34a")      // Green
            case .emeraldViolet: return Color(hex: "8b5cf6")  // Violet
            }
        }
        
        // Light background color
        var backgroundColor: Color {
            Color(.systemGroupedBackground)
        }
        
        // Card/surface color
        var cardColor: Color {
            Color(.secondarySystemGroupedBackground)
        }
    }
    
    // Method to change theme
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
}

// MARK: - Color Extension
// Helper to create colors from hex codes (like #0d9488)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
