import SwiftUI
import Combine

// MARK: - App Theme System

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme = .emeraldViolet

    init() {
        if let saved = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: saved) {
            currentTheme = theme
        }
    }

    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "selectedTheme")
    }

    // MARK: - Theme Categories
    enum ThemeCategory: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case vibrant = "Vibrant"
    }

    // MARK: - App Themes
    enum AppTheme: String, CaseIterable, Identifiable {
        // Light
        case emeraldViolet = "Emerald & Violet"
        case oceanBreeze = "Ocean Breeze"
        case rosePetal = "Rose Petal"
        case lavenderMist = "Lavender Mist"
        case sunsetCoral = "Sunset Coral"
        case forestSage = "Forest & Sage"
        // Dark
        case midnightBlue = "Midnight Blue"
        case cosmicPurple = "Cosmic Purple"
        case obsidian = "Obsidian"
        case midnightRose = "Midnight Rose"
        // Vibrant
        case tropicalVibes = "Tropical Vibes"
        case electricNight = "Electric Night"

        var id: String { rawValue }

        var category: ThemeCategory {
            switch self {
            case .emeraldViolet, .oceanBreeze, .rosePetal, .lavenderMist, .sunsetCoral, .forestSage:
                return .light
            case .midnightBlue, .cosmicPurple, .obsidian, .midnightRose:
                return .dark
            case .tropicalVibes, .electricNight:
                return .vibrant
            }
        }

        var primaryColor: Color {
            switch self {
            case .emeraldViolet: return Color(hex: "10b981")
            case .oceanBreeze:   return Color(hex: "0284c7")
            case .rosePetal:     return Color(hex: "e11d48")
            case .lavenderMist:  return Color(hex: "7c3aed")
            case .sunsetCoral:   return Color(hex: "f97316")
            case .forestSage:    return Color(hex: "15803d")
            case .midnightBlue:  return Color(hex: "60a5fa")
            case .cosmicPurple:  return Color(hex: "c084fc")
            case .obsidian:      return Color(hex: "2dd4bf")
            case .midnightRose:  return Color(hex: "fb7185")
            case .tropicalVibes: return Color(hex: "06b6d4")
            case .electricNight: return Color(hex: "60a5fa")
            }
        }

        var accentColor: Color {
            switch self {
            case .emeraldViolet: return Color(hex: "8b5cf6")
            case .oceanBreeze:   return Color(hex: "06b6d4")
            case .rosePetal:     return Color(hex: "d97706")
            case .lavenderMist:  return Color(hex: "a78bfa")
            case .sunsetCoral:   return Color(hex: "ec4899")
            case .forestSage:    return Color(hex: "84cc16")
            case .midnightBlue:  return Color(hex: "34d399")
            case .cosmicPurple:  return Color(hex: "f472b6")
            case .obsidian:      return Color(hex: "a3e635")
            case .midnightRose:  return Color(hex: "fbbf24")
            case .tropicalVibes: return Color(hex: "f43f5e")
            case .electricNight: return Color(hex: "22c55e")
            }
        }

        var backgroundColor: Color {
            switch self {
            case .emeraldViolet: return Color(red: 0.95, green: 0.99, blue: 0.97)
            case .oceanBreeze:   return Color(red: 0.93, green: 0.97, blue: 1.00)
            case .rosePetal:     return Color(red: 1.00, green: 0.95, blue: 0.96)
            case .lavenderMist:  return Color(red: 0.97, green: 0.95, blue: 1.00)
            case .sunsetCoral:   return Color(red: 1.00, green: 0.97, blue: 0.94)
            case .forestSage:    return Color(red: 0.94, green: 0.98, blue: 0.94)
            case .midnightBlue:  return Color(red: 0.05, green: 0.10, blue: 0.20)
            case .cosmicPurple:  return Color(red: 0.07, green: 0.04, blue: 0.14)
            case .obsidian:      return Color(red: 0.06, green: 0.06, blue: 0.07)
            case .midnightRose:  return Color(red: 0.10, green: 0.07, blue: 0.09)
            case .tropicalVibes: return Color(red: 0.92, green: 0.99, blue: 0.98)
            case .electricNight: return Color(red: 0.04, green: 0.04, blue: 0.09)
            }
        }

        var cardColor: Color {
            switch self {
            case .emeraldViolet, .oceanBreeze, .rosePetal,
                 .lavenderMist, .sunsetCoral, .forestSage, .tropicalVibes:
                return .white
            case .midnightBlue:  return Color(red: 0.08, green: 0.14, blue: 0.26)
            case .cosmicPurple:  return Color(red: 0.12, green: 0.08, blue: 0.20)
            case .obsidian:      return Color(red: 0.12, green: 0.12, blue: 0.13)
            case .midnightRose:  return Color(red: 0.16, green: 0.11, blue: 0.14)
            case .electricNight: return Color(red: 0.08, green: 0.08, blue: 0.15)
            }
        }

        var fontDesign: Font.Design {
            switch self {
            case .emeraldViolet, .rosePetal, .forestSage, .midnightBlue, .obsidian, .midnightRose:
                return .default
            case .oceanBreeze, .lavenderMist, .sunsetCoral, .cosmicPurple, .tropicalVibes:
                return .rounded
            case .electricNight:
                return .monospaced
            }
        }

        var colorScheme: ColorScheme {
            switch self {
            case .midnightBlue, .cosmicPurple, .obsidian, .midnightRose, .electricNight:
                return .dark
            default:
                return .light
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
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
